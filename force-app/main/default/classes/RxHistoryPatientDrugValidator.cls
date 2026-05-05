public without sharing class RxHistoryPatientDrugValidator {

    public class ResultWrapper {
        @AuraEnabled public String  categoryName;
        @AuraEnabled public String  found;
        @AuraEnabled public Integer totalQuantity;
        @AuraEnabled public Integer totalDaysSupply;
        @AuraEnabled public Boolean threshold;
        @AuraEnabled public Integer lookbackWindow;
        @AuraEnabled public Integer gracePeriod;
        @AuraEnabled public Integer totalGapDays;
        @AuraEnabled public String  breakReason;  
        @AuraEnabled public Boolean isFirstChain;

        public ResultWrapper(
            String  categoryName, String  found,
            Integer totalQuantity, Integer totalDaysSupply,
            Boolean threshold, Integer lookbackWindow,
            Integer gracePeriod, Integer totalGapDays,
            String  breakReason, Boolean isFirstChain
        ) {
            this.categoryName    = categoryName;
            this.found           = found;
            this.totalQuantity   = totalQuantity;
            this.totalDaysSupply = totalDaysSupply;
            this.threshold       = threshold;
            this.lookbackWindow  = lookbackWindow;
            this.gracePeriod     = gracePeriod;
            this.totalGapDays    = totalGapDays;
            this.breakReason     = breakReason;
            this.isFirstChain    = isFirstChain;
        }
    }

    private class CategoryInfo {
        public String       name;
        public Integer      lookbackWindow;
        public Integer      gracePeriod;
        public Integer      threshold;
        public Set<Integer> dins;

        public CategoryInfo(String name, Integer lb, Integer gp, Integer th) {
            this.name           = name;
            this.lookbackWindow = (lb != null) ? lb : 0;
            this.gracePeriod    = (gp != null) ? gp : 0;
            this.threshold      = (th != null) ? th : 0;
            this.dins           = new Set<Integer>();
        }

        public Date getEarliestDate() {
            return Date.today().addDays(-this.lookbackWindow);
        }
    }

    private class MedRecord implements Comparable {
        public Integer dinpin;
        public Date    dateDispensed;
        public Integer daysSupply;
        public Integer quantity;

        public MedRecord(Integer d, Date dt, Integer ds, Integer q) {
            this.dinpin        = d;
            this.dateDispensed = dt;
            this.daysSupply    = (ds != null && ds > 0) ? ds : 0;
            this.quantity      = (q  != null && q  > 0) ? q  : 0;
        }

        public Date getCoverageEndDate() {
            if (this.dateDispensed == null || this.daysSupply <= 0) {
                return this.dateDispensed;
            }
            return this.dateDispensed.addDays(this.daysSupply - 1);
        }

        public Integer compareTo(Object o) {
            MedRecord other = (MedRecord) o;
            if (this.dateDispensed == null && other.dateDispensed == null) return 0;
            if (this.dateDispensed == null)  return  1;
            if (other.dateDispensed == null) return -1;
            if (this.dateDispensed < other.dateDispensed) return -1;
            if (this.dateDispensed > other.dateDispensed) return  1;
            return 0;
        }
    }

    private class ChainResult {
        public Integer totalDaysSupply;
        public Integer totalQuantity;
        public Integer cumulativeGap;
        public String  breakReason;
        public Boolean meetsThreshold;
        public Integer chainIndex;
        public Date    firstDispense;
        public Date    lastDispense;

        public ChainResult(Integer idx) {
            this.chainIndex      = idx;
            this.totalDaysSupply = 0;
            this.totalQuantity   = 0;
            this.cumulativeGap   = 0;
            this.breakReason     = '';
            this.meetsThreshold  = false;
            this.firstDispense   = null;
            this.lastDispense    = null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ResultWrapper> validateDrugStep(Id caseId) {

        if (caseId == null) {
            throw new AuraHandledException('Case Id cannot be null');
        }

        Case c = [
            SELECT Id, Drug_Name__c
            FROM   Case
            WHERE  Id = :caseId
            LIMIT  1
        ];

        if (String.isBlank(c.Drug_Name__c)) {
            return new List<ResultWrapper>();
        }

        List<Step_Criteria__c> criteriaList = [
            SELECT Id, Field_Name__c,Step__r.Compliance_Logic__c
            FROM   Step_Criteria__c
            WHERE  Step__r.Drug__r.Name = :c.Drug_Name__c
              AND  Object_Name__c       = 'Rx History'
            ORDER BY Order__c ASC
        ];

        if (criteriaList.isEmpty()) {
            return new List<ResultWrapper>();
        }

        Set<String> categoryNames = new Set<String>();
        for (Step_Criteria__c sc : criteriaList) {
            if (String.isNotBlank(sc.Field_Name__c)) {
                for (String n : sc.Field_Name__c.split(',')) {
                    String trimmed = n.trim();
                    if (String.isNotBlank(trimmed)) {
                        categoryNames.add(trimmed);
                    }
                }
            }
        }

        if (categoryNames.isEmpty()) {
            return new List<ResultWrapper>();
        }

        Map<String, CategoryInfo> catInfoMap = new Map<String, CategoryInfo>();

        for (Din_List_Category__c cat : [
            SELECT Name, DINs__c, Lookback_Window__c, Grace_Period__c, Threshold__c
            FROM   Din_List_Category__c
            WHERE  Name IN :categoryNames
        ]) {
            catInfoMap.put(
                cat.Name,
                buildCategoryInfo(
                    cat.Name, cat.Lookback_Window__c,
                    cat.Grace_Period__c, cat.Threshold__c, cat.DINs__c
                )
            );
        }

        for (Product_Health_Category__c cat : [
            SELECT Name, DINs__c, Lookback_Window__c, Grace_Period__c, Threshold__c
            FROM   Product_Health_Category__c
            WHERE  Name IN :categoryNames
        ]) {
            if (!catInfoMap.containsKey(cat.Name)) {
                catInfoMap.put(
                    cat.Name,
                    buildCategoryInfo(
                        cat.Name, cat.Lookback_Window__c,
                        cat.Grace_Period__c, cat.Threshold__c, cat.DINs__c
                    )
                );
            }
        }

        Set<Integer> allDins = new Set<Integer>();
        for (CategoryInfo ci : catInfoMap.values()) {
            allDins.addAll(ci.dins);
        }

        if (allDins.isEmpty()) {
            return new List<ResultWrapper>();
        }
        PrescriptionHistoryResponse resObj =
            ODRIntegration.fetchPrescriptionHistory(
                caseId, '1', '799',
                new List<Integer>(allDins)
            );

        List<MedRecord> allRecords = new List<MedRecord>();

        if (resObj != null
            && resObj.medHistory != null
            && resObj.medHistory.medRecords != null) {
            for (PrescriptionHistoryResponse.MedRecords rec
                 : resObj.medHistory.medRecords) {

                if (rec.dinpin == null) continue;

                Date dt = null;
                if (String.isNotBlank(rec.dateDispensed)) {
                    dt = Date.valueOf(rec.dateDispensed);
                }

                allRecords.add(new MedRecord(
                    rec.dinpin,
                    dt,
                    rec.daysSupply != null ? Integer.valueOf(rec.daysSupply) : 0,
                    rec.quantity   != null ? Integer.valueOf(rec.quantity)   : 0
                ));
            }
        }

        List<ResultWrapper> results = new List<ResultWrapper>();
        Date today = Date.today();

        for (String catName : catInfoMap.keySet()) {

            CategoryInfo ci       = catInfoMap.get(catName);
            Boolean graceBlank    = (ci.gracePeriod == null || ci.gracePeriod == 0);
            Boolean threshBlank   = (ci.threshold   == null || ci.threshold   == 0);
        
            
            Date         earliest = (ci.lookbackWindow > 0)
                                    ? ci.getEarliestDate()
                                    : null;

            List<MedRecord> filtered = new List<MedRecord>();
            for (MedRecord rec : allRecords) {
                if (!ci.dins.contains(rec.dinpin))   continue;
                if (rec.dateDispensed == null)        continue;
                if (rec.daysSupply    <= 0)           continue;
                if (rec.dateDispensed > today)        continue;
                if (earliest != null
                    && rec.dateDispensed < earliest)  continue;
                filtered.add(rec);
            }

            filtered.sort();

            ResultWrapper rw = evaluateChains(filtered, ci, catName);
            if (graceBlank && threshBlank) {
                rw.found       = 'false'; 
                rw.threshold   = false;  
                rw.isFirstChain = false; 
                rw.totalDaysSupply = 0;
                
            }
            results.add(rw);
        }

        System.debug('results ==== ' + results);
        return results;
    }

    private static ResultWrapper evaluateChains(
    List<MedRecord> sorted,
    CategoryInfo    ci,
    String          catName
) {
    Date today = Date.today();

    if (sorted.isEmpty()) {
        return new ResultWrapper(
            catName, 'false', 0, 0, false,
            ci.lookbackWindow, ci.gracePeriod, 0,
            'No prescription records found for this category',
            false
        );
    }

    // ── Total quantity ALL records unconditionally ─────────────────────────
    Integer totalQuantityAllRecords = 0;
    for (MedRecord rec : sorted) {
        totalQuantityAllRecords += rec.quantity;
    }

    // ── gracePeriod=0: gaps NOT allowed, chain breaks on any gap > 0 ───────
    if (ci.gracePeriod == 0 && ci.threshold > 0) {

        System.debug('>>> ENTERING gracePeriod=0 branch'
            + ' threshold=' + ci.threshold);

        List<ChainResult> chains0       = new List<ChainResult>();
        Integer           chainIndex0   = 0;
        ChainResult       current0      = new ChainResult(chainIndex0);
        Date              chainEndDate0 = null;

        for (Integer i = 0; i < sorted.size(); i++) {

            MedRecord rec    = sorted.get(i);
            Date      covEnd = capDate(rec.getCoverageEndDate(), today);

            System.debug('grace=0 Rec[' + i + ']'
                + ' date='       + rec.dateDispensed
                + ' daysSupply=' + rec.daysSupply
                + ' covEnd='     + covEnd
                + ' chainEnd='   + chainEndDate0
                + ' curDays='    + current0.totalDaysSupply);

            // ── First record in chain ──────────────────────────────────────
            if (chainEndDate0 == null) {
                chainEndDate0             = covEnd;
                current0.totalDaysSupply += rec.daysSupply;
                current0.firstDispense    = rec.dateDispensed;
                current0.lastDispense     = rec.dateDispensed;

                System.debug('  grace=0 FIRST +' + rec.daysSupply
                    + ' total=' + current0.totalDaysSupply);

                // ✅ STOP if threshold met
                if (current0.totalDaysSupply >= ci.threshold) {
                    System.debug('>>> grace=0 THRESHOLD MET Rec[' + i + ']'
                        + ' days=' + current0.totalDaysSupply);
                    break;
                }
                continue;
            }

            Integer gap0 = chainEndDate0.daysBetween(rec.dateDispensed) - 1;

            System.debug('  grace=0 gap=' + gap0);

            // ── Overlap or back to back (gap <= 0) ────────────────────────
            if (gap0 <= 0) {
                current0.totalDaysSupply += rec.daysSupply;
                current0.lastDispense     = rec.dateDispensed;
                
                // ✅ FIX: Stack coverage from END of current chain
                chainEndDate0 = chainEndDate0.addDays(rec.daysSupply);
                
                // Cap at today
                if (chainEndDate0 > today) {
                    chainEndDate0 = today;
                }

                System.debug('  grace=0 OVERLAP/BTB +' + rec.daysSupply
                    + ' total=' + current0.totalDaysSupply
                    + ' newChainEnd=' + chainEndDate0);

                // ✅ STOP if threshold met
                if (current0.totalDaysSupply >= ci.threshold) {
                    System.debug('>>> grace=0 THRESHOLD MET Rec[' + i + ']'
                        + ' days=' + current0.totalDaysSupply);
                    break;
                }
                continue;
            }

            // ── Gap > 0 with grace=0 → CHAIN BREAK ────────────────────────
            current0.meetsThreshold = (current0.totalDaysSupply >= ci.threshold);
            current0.breakReason    =
                'Chain ' + (chainIndex0 + 1)
                + ': Gap of ' + gap0
                + ' days. Grace=0 so chain breaks.'
                + ' Total: ' + current0.totalDaysSupply + ' days.'
                + ' Meets: ' + current0.meetsThreshold  + '.';

            System.debug('grace=0 CHAIN BREAK Rec[' + i + ']'
                + ' gap='   + gap0
                + ' days='  + current0.totalDaysSupply
                + ' meets=' + current0.meetsThreshold);

            chains0.add(current0);

            // ── If broken chain meets threshold → STOP ─────────────────────
            if (current0.meetsThreshold) {
                System.debug('>>> grace=0 BROKEN CHAIN MET THRESHOLD → STOP');
                break;
            }

            // ── Start new chain ────────────────────────────────────────────
            chainIndex0++;
            current0                  = new ChainResult(chainIndex0);
            chainEndDate0             = covEnd;
            current0.totalDaysSupply += rec.daysSupply;
            current0.firstDispense    = rec.dateDispensed;
            current0.lastDispense     = rec.dateDispensed;

            System.debug('grace=0 NEW CHAIN ' + chainIndex0
                + ' days='  + rec.daysSupply
                + ' total=' + current0.totalDaysSupply);

            // ✅ STOP if new chain meets threshold
            if (current0.totalDaysSupply >= ci.threshold) {
                System.debug('>>> grace=0 THRESHOLD MET Rec[' + i + ']'
                    + ' days=' + current0.totalDaysSupply);
                break;
            }
        }

        // ── Finalise last chain ────────────────────────────────────────────
        if (current0.totalDaysSupply > 0) {
            current0.meetsThreshold = (current0.totalDaysSupply >= ci.threshold);
            current0.breakReason    = current0.meetsThreshold
                ? 'Chain ' + (chainIndex0 + 1)
                  + ': Verified '   + String.valueOf(current0.firstDispense)
                  + ' to '          + String.valueOf(current0.lastDispense)
                  + '. Total: '     + current0.totalDaysSupply + ' days.'
                : 'Chain ' + (chainIndex0 + 1)
                  + ': Total ('     + current0.totalDaysSupply
                  + ') below threshold (' + ci.threshold + ').';
            chains0.add(current0);
        }

        // ── Find first winning chain ───────────────────────────────────────
        Integer winIdx0 = -1;
        for (Integer i = 0; i < chains0.size(); i++) {
            if (chains0.get(i).meetsThreshold) {
                winIdx0 = i;
                break;
            }
        }

        Boolean isFirst0 = (winIdx0 == 0);
        Boolean passed0  = isFirst0;

        Integer dispDays0 = winIdx0 >= 0
            ? chains0.get(winIdx0).totalDaysSupply
            : chains0.get(0).totalDaysSupply;

        String reason0 = buildChainSummary(
            chains0, ci, passed0, winIdx0
        );

        System.debug('=== grace=0 FINAL RESULT ==='
            + ' days='      + dispDays0
            + ' qty='       + totalQuantityAllRecords
            + ' threshold=' + ci.threshold
            + ' passed='    + passed0
            + ' isFirst='   + isFirst0);

        return new ResultWrapper(
            catName,
            String.valueOf(passed0),
            totalQuantityAllRecords,
            dispDays0,
            (dispDays0 >= ci.threshold),
            ci.lookbackWindow,
            ci.gracePeriod,
            0,
            reason0,
            isFirst0
        );
    }

    // ── Normal chain logic (gracePeriod > 0) ──────────────────────────────
    System.debug('>>> ENTERING normal chain logic'
        + ' gracePeriod=' + ci.gracePeriod
        + ' threshold='   + ci.threshold);

    List<ChainResult>    chains          = new List<ChainResult>();
    List<List<Integer>>  chainRecordIdxs = new List<List<Integer>>();

    Integer       chainIndex   = 0;
    ChainResult   current      = new ChainResult(chainIndex);
    List<Integer> currentIdx   = new List<Integer>();
    Date          chainEndDate = null;

    for (Integer i = 0; i < sorted.size(); i++) {

        MedRecord rec       = sorted.get(i);
        Integer   daysToAdd = rec.daysSupply;
        Date      covEnd    = capDate(rec.getCoverageEndDate(), today);

        System.debug('Rec[' + i + ']'
            + ' date='       + rec.dateDispensed
            + ' daysSupply=' + rec.daysSupply
            + ' covEnd='     + covEnd
            + ' chainEnd='   + chainEndDate
            + ' curDays='    + current.totalDaysSupply);

        // ── First record in chain ──────────────────────────────────────────
        if (chainEndDate == null) {
            chainEndDate             = covEnd;
            current.totalDaysSupply += daysToAdd;
            current.firstDispense    = rec.dateDispensed;
            current.lastDispense     = rec.dateDispensed;
            currentIdx.add(i);

            System.debug('  FIRST +' + daysToAdd
                + ' total=' + current.totalDaysSupply);

            // ✅ STOP if threshold met
            if (current.totalDaysSupply >= ci.threshold) {
                System.debug('>>> THRESHOLD MET at Rec[' + i + ']'
                    + ' days=' + current.totalDaysSupply);
                break;
            }
            continue;
        }

        Integer gap = chainEndDate.daysBetween(rec.dateDispensed) - 1;

        System.debug('  gap='    + gap
            + ' cumGap=' + current.cumulativeGap);

        // ── Overlap (gap < 0) ──────────────────────────────────────────────
        if (gap < 0) {
            current.totalDaysSupply += daysToAdd;
            current.lastDispense     = rec.dateDispensed;
            
            // ✅ FIX: Stack coverage from END of current chain
            chainEndDate = chainEndDate.addDays(daysToAdd);
            
            // Cap at today
            if (chainEndDate > today) {
                chainEndDate = today;
            }
            
            currentIdx.add(i);

            System.debug('  OVERLAP +' + daysToAdd
                + ' total=' + current.totalDaysSupply
                + ' newChainEnd=' + chainEndDate);

            // ✅ STOP if threshold met
            if (current.totalDaysSupply >= ci.threshold) {
                System.debug('>>> THRESHOLD MET at Rec[' + i + ']'
                    + ' days=' + current.totalDaysSupply);
                break;
            }
            continue;
        }

        // ── Back to back (gap = 0) ─────────────────────────────────────────
        if (gap == 0) {
            current.totalDaysSupply += daysToAdd;
            current.lastDispense     = rec.dateDispensed;
            chainEndDate             = covEnd;
            currentIdx.add(i);

            System.debug('  BACK-TO-BACK +' + daysToAdd
                + ' total=' + current.totalDaysSupply);

            // ✅ STOP if threshold met
            if (current.totalDaysSupply >= ci.threshold) {
                System.debug('>>> THRESHOLD MET at Rec[' + i + ']'
                    + ' days=' + current.totalDaysSupply);
                break;
            }
            continue;
        }

        // ── Gap > 0: check against grace period ───────────────────────────
        Integer prospectiveCumGap = current.cumulativeGap + gap;

        if (prospectiveCumGap <= ci.gracePeriod) {
            // ── Within grace ───────────────────────────────────────────────
            current.cumulativeGap    = prospectiveCumGap;
            current.totalDaysSupply += daysToAdd;
            current.lastDispense     = rec.dateDispensed;
            chainEndDate             = covEnd;
            currentIdx.add(i);

            System.debug('  IN GRACE gap='  + gap
                + ' cumGap='  + prospectiveCumGap
                + ' +'        + daysToAdd
                + ' total='   + current.totalDaysSupply);

            // ✅ STOP if threshold met
            if (current.totalDaysSupply >= ci.threshold) {
                System.debug('>>> THRESHOLD MET at Rec[' + i + ']'
                    + ' days=' + current.totalDaysSupply);
                break;
            }

        } else {
            // ── Chain break ────────────────────────────────────────────────
            current.meetsThreshold = (current.totalDaysSupply >= ci.threshold);
            current.breakReason    =
                'Chain ' + (chainIndex + 1)
                + ': Gap '    + prospectiveCumGap
                + ' exceeds grace ' + ci.gracePeriod
                + '. Total: ' + current.totalDaysSupply + ' days.'
                + ' Meets: '  + current.meetsThreshold  + '.';

            System.debug('CHAIN BREAK Rec[' + i + ']'
                + ' cumGap='  + prospectiveCumGap
                + ' > grace=' + ci.gracePeriod
                + ' days='    + current.totalDaysSupply
                + ' meets='   + current.meetsThreshold);

            chains.add(current);
            chainRecordIdxs.add(currentIdx);

            // ── If broken chain meets threshold → STOP ─────────────────────
            if (current.meetsThreshold) {
                System.debug('>>> BROKEN CHAIN MET THRESHOLD → STOP');
                break;
            }

            // ── Start new chain ────────────────────────────────────────────
            chainIndex++;
            current                  = new ChainResult(chainIndex);
            currentIdx               = new List<Integer>();
            chainEndDate             = covEnd;
            current.totalDaysSupply += daysToAdd;
            current.firstDispense    = rec.dateDispensed;
            current.lastDispense     = rec.dateDispensed;
            currentIdx.add(i);

            System.debug('NEW CHAIN ' + chainIndex
                + ' days='  + daysToAdd
                + ' total=' + current.totalDaysSupply);

            // ✅ STOP if new chain meets threshold
            if (current.totalDaysSupply >= ci.threshold) {
                System.debug('>>> THRESHOLD MET at Rec[' + i + ']'
                    + ' days=' + current.totalDaysSupply);
                break;
            }
        }
    }

    // ── Finalise current chain ─────────────────────────────────────────────
    if (current.totalDaysSupply > 0 || currentIdx.size() > 0) {
        current.meetsThreshold = (current.totalDaysSupply >= ci.threshold);
        current.breakReason    = current.meetsThreshold
            ? 'Chain ' + (chainIndex + 1)
              + ': Verified '   + String.valueOf(current.firstDispense)
              + ' to '          + String.valueOf(current.lastDispense)
              + '. Total: '     + current.totalDaysSupply + ' days.'
              + ' Gap used: '   + current.cumulativeGap
              + ' of '          + ci.gracePeriod + ' allowed.'
            : 'Chain ' + (chainIndex + 1)
              + ': Total ('     + current.totalDaysSupply
              + ') below threshold (' + ci.threshold + ').'
              + ' Gap used: '   + current.cumulativeGap
              + ' of '          + ci.gracePeriod + ' allowed.';
        chains.add(current);
        chainRecordIdxs.add(currentIdx);
    }

    // ── Find first winning chain ───────────────────────────────────────────
    Integer winningChainIndex = -1;
    for (Integer i = 0; i < chains.size(); i++) {
        if (chains.get(i).meetsThreshold) {
            winningChainIndex = i;
            break;
        }
    }

    Boolean isFirstChain     = (winningChainIndex == 0);
    Boolean compliancePassed = isFirstChain;

    Integer displayDaysSupply = winningChainIndex >= 0
        ? chains.get(winningChainIndex).totalDaysSupply
        : chains.get(0).totalDaysSupply;

    Integer displayGap = winningChainIndex >= 0
        ? chains.get(winningChainIndex).cumulativeGap
        : chains.get(0).cumulativeGap;

    String fullReason = buildChainSummary(
        chains, ci, compliancePassed, winningChainIndex
    );

    System.debug('=== FINAL RESULT ==='
        + ' catName='   + catName
        + ' days='      + displayDaysSupply
        + ' qty='       + totalQuantityAllRecords
        + ' threshold=' + ci.threshold
        + ' passed='    + compliancePassed
        + ' isFirst='   + isFirstChain);

    return new ResultWrapper(
        catName,
        String.valueOf(compliancePassed),
        totalQuantityAllRecords,
        displayDaysSupply,
        (displayDaysSupply >= ci.threshold),
        ci.lookbackWindow,
        ci.gracePeriod,
        displayGap,
        fullReason,
        isFirstChain
    );
}

    private static Date capDate(Date d, Date maxDate) {
        if (d == null)      return maxDate;
        if (d > maxDate)    return maxDate;
        return d;
    }

    private static String buildChainSummary(
        List<ChainResult> chains,
        CategoryInfo      ci,
        Boolean           passed,
        Integer           winningChainIndex
    ) {
        List<String> parts = new List<String>();

        parts.add(
            'Compliance: ' + (passed ? 'TRUE' : 'FALSE') + '.'
            + (passed
                ? ' Winning chain: Chain ' + (winningChainIndex + 1) + '.'
                : (winningChainIndex >= 0
                    ? ' Chain ' + (winningChainIndex + 1)
                      + ' met threshold but was not the first chain.'
                    : ' No chain met the threshold of ' + ci.threshold + ' days.'))
        );

        for (Integer i = 0; i < chains.size(); i++) {
            ChainResult ch  = chains.get(i);
            String      tag = '';
            if (i == winningChainIndex) {
                tag = (i == 0) ? ' ← PASSED (first chain)' : ' ← MET THRESHOLD (not first chain → FALSE)';
            }
            parts.add(
                'Chain ' + (i + 1)
                + ' [' + String.valueOf(ch.firstDispense)
                + ' → ' + String.valueOf(ch.lastDispense) + ']'
                + ': ' + ch.totalDaysSupply + ' days'
                + ', gap used: ' + ch.cumulativeGap
                + '/' + ci.gracePeriod
                + ', meets threshold: ' + ch.meetsThreshold
                + tag + '. ' + ch.breakReason
            );
        }

        return String.join(parts, ' | ');
    }

    private static CategoryInfo buildCategoryInfo(
        String  name, Decimal lb, Decimal gp,
        Decimal th,   String  dinsStr
    ) {
        CategoryInfo ci = new CategoryInfo(
            name,
            lb != null ? Integer.valueOf(lb) : 0,
            gp != null ? Integer.valueOf(gp) : 0,
            th != null ? Integer.valueOf(th) : 0
        );
        ci.dins = parseDins(dinsStr);
        return ci;
    }

    private static Set<Integer> parseDins(String dinsStr) {
        Set<Integer> s = new Set<Integer>();
        if (String.isNotBlank(dinsStr)) {
            for (String v : dinsStr.split(',')) {
                v = v.trim();
                if (String.isNotBlank(v)) {
                    try {
                        s.add(Integer.valueOf(v));
                    } catch (Exception e) {
                        System.debug('Invalid DIN value: ' + v);
                    }
                }
            }
        }
        return s;
    }
    
    @future(callout=true)
    public static void validateAndUpdateCase(Id caseId) {
        if (caseId == null) return;
    
        Case caserec = [
            SELECT Id, Drug_Name__c
            FROM   Case
            WHERE  Id = :caseId
            LIMIT  1
        ];
    
        List<Step_Criteria__c> criteriaList = [
            SELECT Id, Field_Name__c, Compliance_Logic__c, Compliance_Met__c
            FROM   Step_Criteria__c
            WHERE  Step__r.Drug__r.Name = :caserec.Drug_Name__c
              AND  Object_Name__c       = 'Rx History'
            ORDER BY Order__c ASC
        ];
    
        if (criteriaList == null || criteriaList.isEmpty()) return;
    
        List<ResultWrapper> results = validateDrugStep(caseId);
        System.debug('results==' + results);
    
        if (results == null || results.isEmpty()) return;
    
        // Build a map of category name to isFirstChain value
        Map<String, Boolean> categoryResultMap = new Map<String, Boolean>();
        for (ResultWrapper rw : results) {
            if (String.isNotBlank(rw.categoryName)) {
                categoryResultMap.put(rw.categoryName.trim(), rw.threshold);
            }
        }
    
        System.debug('categoryResultMap=' + categoryResultMap);
    
        // Process each Step_Criteria__c record
        String overallCompliance = 'True';
    
        for (Step_Criteria__c criteria : criteriaList) {
            String complianceLogic = String.isNotBlank(criteria.Compliance_Logic__c) 
                ? criteria.Compliance_Logic__c.trim() 
                : '';
            String complianceMet = String.isNotBlank(criteria.Compliance_Met__c) 
                ? criteria.Compliance_Met__c.trim() 
                : '';
    
            System.debug('Processing criteria: ' + criteria.Id);
            System.debug('complianceLogic=' + complianceLogic);
            System.debug('complianceMet=' + complianceMet);
    
            if (String.isBlank(complianceLogic)) continue;
    
            // Parse comma-separated category names
            Set<String> requiredCategories = new Set<String>();
            for (String category : complianceLogic.split(',')) {
                if (String.isNotBlank(category)) {
                    requiredCategories.add(category.trim());
                }
            }
    
            System.debug('requiredCategories=' + requiredCategories);
    
            Boolean expectTrue = (complianceMet.equalsIgnoreCase('true'));
            System.debug('expectTrue=' + expectTrue);
    
            // Check if all required categories match the expected compliance state
            Boolean criteriaCompliance = true;
            for (String categoryName : requiredCategories) {
                Boolean actualValue = categoryResultMap.get(categoryName);
                
                System.debug('Checking category: ' + categoryName + 
                             ', actualValue=' + actualValue + 
                             ', expectTrue=' + expectTrue);
    
                if (actualValue == null) {
                    // Category not found in results
                    criteriaCompliance = false;
                    System.debug('Category not found in results: ' + categoryName);
                    break;
                }
    
                if (expectTrue) {
                    // Compliance_Met__c = true: all required categories must be true
                    if (actualValue != true) {
                        criteriaCompliance = false;
                        System.debug('Expected true but got false for: ' + categoryName);
                        break;
                    }
                } else {
                    // Compliance_Met__c = false: all required categories must be false
                    if (actualValue != false) {
                        criteriaCompliance = false;
                        System.debug('Expected false but got true for: ' + categoryName);
                        break;
                    }
                }
            }
    
    
            // If any criteria fails, overall compliance is false
            if (!criteriaCompliance) {
                overallCompliance = 'False';
                break;
            }
        }
    
        System.debug('Final overallCompliance=' + overallCompliance);
        System.debug('caseId=' + caseId);
    
        Case c = new Case(
            Id            = caseId,
            Compliance__c = overallCompliance
        );
        update c;
    
        AdjudicationService.evaluateDirect(caseId, true);
    }
}