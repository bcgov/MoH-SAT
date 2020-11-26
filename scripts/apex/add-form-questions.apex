public class FormResponse {
    public String question { get; set; }
    public String stringValue { get; set; }
}

String jsonString = '[{"question":"Displ oblique fx shaft of unsp fibula, 7thD","stringValue":"Dental examination"},{"question":"Unspecified acquired deformity of unspecified limb","stringValue":"Other incision of esophagus"},{"question":"Fascioliasis","stringValue":"Suture of laceration of diaphragm"},{"question":"Path fx in neopltc disease, r radius, subs for fx w malunion","stringValue":"Other incision of conjunctiva"},{"question":"Unsp injury of branches of celiac and mesenteric artery","stringValue":"Arteriography of other intrathoracic vessels"},{"question":"Toxic effect of unsp corrosive substance, acc, sequela","stringValue":"Creation of conduit between left ventricle and aorta"},{"question":"Inj musc/fasc/tend at thigh level, left thigh, sequela","stringValue":"Biopsy of chest wall"},{"question":"Contact urticaria","stringValue":"Other local excision or destruction of lesion of joint, hip"},{"question":"Disp fx of prox phalanx of finger, subs for fx w delay heal","stringValue":"Other fusion of foot"},{"question":"Other myositis, right ankle and foot","stringValue":"Other insertion of colonic stent(s)"},{"question":"Sudden idiopathic hearing loss, right ear","stringValue":"Arteriography using contrast material, unspecified site"},{"question":"30 weeks gestation of pregnancy","stringValue":"Other partial breech extraction"},{"question":"Rheumatoid myopathy w rheumatoid arthritis of right shoulder","stringValue":"Pneumoencephalogram"},{"question":"Partial traumatic amp of unsp forearm, level unsp, init","stringValue":"Microscopic examination of specimen from kidney, ureter, perirenal and periureteral tissue, cell block and Papanicolaou smear"},{"question":"Coma scale, best verb, incomprehensible words, EMR","stringValue":"Suture of laceration of vas deferens and epididymis"},{"question":"Burn of first degree of left hand, unspecified site","stringValue":"Other plastic repair of mouth"},{"question":"Nondisp oblique fx shaft of l tibia, 7thP","stringValue":"Other diagnostic procedures on cervix"},{"question":"Chronic myeloid leukemia, BCR/ABL-positive","stringValue":"Gastric cooling"},{"question":"Unsp fracture of left forearm, subs for clos fx w malunion","stringValue":"Other endovascular procedures on other vessels"},{"question":"Antepartum hemorrhage with afibrinogenemia","stringValue":"Intubation of nasolacrimal duct"},{"question":"Milt op w indirect blast effect of nuclear weapon, civ, subs","stringValue":"Control of (postoperative) hemorrhage of prostate"},{"question":"Accident to, on or involving cable-car, not on rails, init","stringValue":"Suture of laceration of nose"}]';

List<FormResponse> formResponsesSource = (List<FormResponse>) JSON.deserialize(jsonString, List<FormResponse>.class);
List<Case> cases = [select Id from Case];
List<Request_Detail__c> formResponses = new List<Request_Detail__c>();

for (Case c : cases) {
    for (Integer i = 0; i < 3; i++) {
        Integer randomNumber = Integer.valueof((Math.random() * formResponsesSource.size()));
        FormResponse formResponseSrc = formResponsesSource[randomNumber];
        
        Request_Detail__c formResponse = new Request_Detail__c();
        formResponse.Question__c = formResponseSrc.question;
        formResponse.String_Value__c = formResponseSrc.stringValue;
        formResponse.Sort_Order__c = (i+1)*10;
        formResponse.Case__c = c.Id;
        formResponse.Question_ID__c = formResponseSrc.question.left(10);
        formResponses.add(formResponse);
    }
}

insert formResponses;
