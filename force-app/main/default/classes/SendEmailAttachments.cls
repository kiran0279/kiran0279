/**
* @Class Name: SendEmailAttachments
* @Description: Used for Sending Email Attachments.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 10th Aug, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used for Sending Email Attachments.
* =================================================================================================================
*/
public with sharing class SendEmailAttachments {
	@InvocableMethod
	public static void SendEmailAttachments(List<Id> contractAgreementIdList) {
	List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
	List<EmailTemplate> templates = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Send_Email_Notification_to_Invoicing_Team'];

	// Attach files to the message
	List<APXT_Redlining__Contract_Agreement__c> contractList = [SELECT Id, Recipient__c, OwnerId, (SELECT Id,ContentDocument.LatestPublishedVersion.Title,ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersion.FileExtension, ContentDocument.LatestPublishedVersion.CreatedDate FROM ContentDocumentLinks ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC LIMIT 1) FROM APXT_Redlining__Contract_Agreement__c WHERE Id = :contractAgreementIdList];

	Contact tempContact = new Contact(email = UserInfo.getUserEmail(), Phone = '4152859685', firstName = UserInfo.getUserName(), lastName = UserInfo.getUserName());
	insert tempContact;

	if (!contractList.isEmpty()) {
		for (APXT_Redlining__Contract_Agreement__c contractAgreement : contractList) {
			tempContact.Email = contractAgreement.Recipient__c;
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setToAddresses(new String[] {contractAgreement.Recipient__c});
			if (!templates.isEmpty()) {
				message.setTemplateId(templates[0].Id);
			}
			message.setWhatId(contractAgreement.Id);
			message.setTargetObjectId(tempContact.Id); 
			message.setSaveAsActivity(false);

			List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
			for (ContentDocumentLink cdl : contractAgreement.ContentDocumentLinks) {
				List<String> nameSplit = cdl.ContentDocument.LatestPublishedVersion.Title.split('\\.');
				Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				efa.setFileName(nameSplit[0] + '.' + cdl.ContentDocument.LatestPublishedVersion.FileExtension);
				efa.setBody(cdl.ContentDocument.LatestPublishedVersion.VersionData);
				efa.setContentType(mimeTypeToFileExtensionsMap.get(cdl.ContentDocument.LatestPublishedVersion.FileExtension));
				attachments.add(efa);
			}

			message.setFileAttachments(attachments);

			messageList.add(message);
		}
		Messaging.SendEmailResult [] results = Messaging.sendEmail(messageList);
		for (Messaging.SendEmailResult result : results) {
			if (result.success) {
				System.debug('The email was sent successfully.');
			} else {
				System.debug('The email failed to send: '
					+ result.errors[0].message);
			}
		}
		
	}
	delete tempContact;
	}

	public static Map<String, String> mimeTypeToFileExtensionsMap = new Map<String, String> {
		'application/pdf'=>'pdf',
		'image/jpeg'=>'jpeg,jpg,jpe',
		'image/gif'=>'gif',
		'image/png'=>'png',
		'application/vnd.ms-excel'=>'xls,xlm,xla,xlc,xlt,xlw',
		'application/vnd.ms-excel.addin.macroenabled.12'=>'xlam',
		'application/vnd.ms-excel.sheet.binary.macroenabled.12'=>'xlsb',
		'application/vnd.ms-excel.sheet.macroenabled.12'=>'xlsm',
		'application/vnd.ms-excel.template.macroenabled.12'=>'xltm',
		'application/vnd.openxmlformats-officedocument.wordprocessingml.document'=>'docx',
		'application/vnd.openxmlformats-officedocument.wordprocessingml.template'=>'dotx',
		'application/msword'=>'doc',
		'application/msword'=>'dot',
		'application/vnd.ms-word.document.macroEnabled.12'=>'docm',
		'application/vnd.ms-word.template.macroEnabled.12'=>'dotm'
	};
}