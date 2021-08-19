public static Task newTask(Id ownerId, String linkUrl) {
    Task task = new Task();
	task.OwnerId = ownerId;    
	task.Priority = 'High';
    task.Status = 'Open';
    task.ActivityDate = Date.today();
    task.Subject = 'Setup your Single Sign-On!';
    task.Description = String.format('{0}\n\n{1}',new String[] {
        'Click the URL below to link your Salesforce and IDIR accounts together.',
         linkUrl
    });
    
    return task;
}

List<Task> tasks = new List<Task>();

for (User user : [select id, name from user where isactive=true and profile.name = 'moh standard user']) {
    Task task = new Task();
    tasks.add(newTask(user.Id, 'https://bchealth--build.my.salesforce.com/services/auth/link/Login_with_IDIR'));
	insert task; 
}

for (User user : [select id, name from user where isactive=true and profile.name in ('HIBC CCPlus Community Users', 'Service BC CCPlus Community Users')]) {
	tasks.add(newTask(user.Id, 'https://build-bchealthcomm.cs138.force.com/services/auth/link/Login_with_IDIR'));
}

insert tasks;

CustomNotificationType inappAlert = [select Id from CustomNotificationType where DeveloperName = 'InAppAlert'];

for (Task task : tasks) {
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle(task.Subject);
    notification.setBody('Click here to start.');
    notification.setNotificationTypeId(inappAlert.Id);
    notification.setTargetId(task.Id);
    notification.send(new Set<String> {task.OwnerId});
}