import { LightningElement, track, api } from 'lwc';
import createDocumentGenerationProcessRequest from '@salesforce/apex/EDRD_cls_generatePDFDoc.createDocumentGenerationProcessRequest';

const columns = [
    { label: 'Heading', fieldName: 'heading' },
    { label: 'Question Name', fieldName: 'question' },
    { label: 'Answer', fieldName: 'answer' }
];

export default class JsonParser extends LightningElement {
    @track jsonInput = '';
    @track parsedJson = '';
    @track keyValuePairs = [];
    @track error = '';
    @track returnList = [];
    @track columns = columns;
    @track data = [];
    @track showDataTable = false;
    @track headingMap = {};
    @track headingList = [];
    @track heading = '';
    @track isInsideDrugQnA = false;
    @api recordId;

    @api
    processJson(jsonResponse, headingList, recordId) {
        this.jsonInput = jsonResponse;
        this.headingMap = JSON.parse(headingList);
        this.recordId = recordId;
        this.handleInputChange();
    }

    handleInputChange() {
        try {
            let modifiedString = this.jsonInput.replace(/\\"/g, "'");
            let parsedData = JSON.parse(modifiedString);
            let assessmentResponseSummary = parsedData.outputValues.assessmentResponseSummary;

            let newString = assessmentResponseSummary.replace(/'/g, '"')
                .replace(/\\\\/g, "'")
                .replace(/\\n/g, '\\n');

            let parsedAssessmentSummary = JSON.parse(newString);
            parsedData.outputValues.assessmentResponseSummary = parsedAssessmentSummary;

            this.parsedJson = JSON.stringify(parsedData, null, 2);
            this.keyValuePairs = Object.entries(parsedData).map(([key, value], index) => ({
                id: index,
                key: key,
                value: typeof value === 'object' ? JSON.stringify(value) : value
            }));

            this.keyValuePairs.forEach(currentItem => {
                if (currentItem.key === 'outputValues') {
                    this.extractQuestionsAndAnswers(JSON.parse(currentItem.value));
                }
            });

            let groupedData = {};

            this.returnList.forEach(currentItem => {
                let resAnswer = currentItem.question === currentItem.answer ? '' : currentItem.answer;

                if (!groupedData[currentItem.heading]) {
                    groupedData[currentItem.heading] = [];
                }

                groupedData[currentItem.heading].push({
                    question: currentItem.question,
                    answer: resAnswer
                });
            });

            this.data = Object.entries(groupedData).map(([heading, qaList]) => ({
                heading,
                questionsAndAnswers: qaList
            }));

            let finalResponses = {};
            finalResponses['RESPONSES'] = this.data;

            let keyVsValue = {};
            keyVsValue['TOKENDATA'] = JSON.stringify(finalResponses);
            keyVsValue['RECORDID'] = this.recordId;

            createDocumentGenerationProcessRequest({ keyVsValue: keyVsValue });

            this.showDataTable = true;

        } catch (err) {
            this.data = this.returnList;
            this.parsedJson = '';
            this.keyValuePairs = [];
            this.error = err.message;
        }
    }

    extractQuestionsAndAnswers(obj) {
        try {
            for (let key in obj) {
                if (this.headingMap[key]) {
                    this.isInsideDrugQnA = true;
                    this.headingList = this.headingMap[key];
                }

                if (this.headingList.includes(obj[key]) && this.isInsideDrugQnA) {
                    this.heading = obj[key];
                }

                if (typeof obj[key] === 'object' && obj[key] !== null && this.isInsideDrugQnA) {
                    if (typeof obj[key].label === 'string' && typeof obj[key].value === 'string' && this.headingList.length !== 1) {
                        if (!obj[key].label.includes('LineBreak') && !obj[key].label.includes('New Submission for:') &&
                            !obj[key].label.includes('PHN:') && !obj[key].label.includes('Drug:')) {
                            this.returnList.push({ question: obj[key].label, answer: obj[key].value, heading: this.heading });
                        }
                    } else {
                        this.extractQuestionsAndAnswers(obj[key]);
                    }
                }
            }
        } catch (err) {
            this.data = this.returnList;
            console.error('Error:', err);
        }
    }
}