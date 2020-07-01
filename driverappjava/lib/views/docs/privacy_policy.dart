import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scrollbar(
          child: ListView(
            children: <Widget>[
              Center(
                child: Text(
                  "Privacy Policy",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                text: TextSpan(
                  text:
                      "We, at transportdesk.in, are concerned about your privacy and its protection is our top priority. When we collect your personal data through our Website, Android and iOS Mobile Application, we do practice certain procedures and it shall be agreed by you that you consent to these practices mentioned in this Privacy Policy document. We have This Privacy Policy governs the manner in which transportdesk.in collects, uses, maintains and discloses information collected from users (each, a \"User\") of the Website or mobile application. This privacy policy applies to this mobile app and services offered by transportdesk.in. If you do not wish to abide by the privacy policy, you may discontinue the use of our services.",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                  children: [
                    TextSpan(
                      text: "\n\nYour Personal Information",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text:
                          "\nWhenever you book a transportation commercial vehicle  through our Website or mobile application, as a part of the service, we have to collect your personal data which includes, the following among others:-",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n 1. Name and Job Title",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                     TextSpan(
                      text: "\n 2. Contact information including phone number and email address",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n 3. Demographic information such as residential address, office address, etc.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n 4. Other information relevant to service enquiry, customer surveys and/or offers.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n \nAll the data collected by us through this app shall be in our safe custody and shall not be deleted unless you do not use our service for a continuous period of one month.\n  All the software and hardware information about your mobile like IP address, browser type, domain names, access timings, etc. will be automatically collected by the Website and Mobile app and this information shall be used by transportdesk.in to operate and maintain the quality of our service.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\nHow we Use Collected Information",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\nTransportdesk.in may collect and use the personal information of users for the following purposes:",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n a.To improve customer service - The information you provide helps us respond to your customer service requests and support needs more efficiently.\n b.To maintain internal records- We may use your information for updating our internal records.\n c.To personalize user experience - We may use information in the aggregate to understand how our Users as a group use the services and resources provided on our Site. \n d. To improve our Site - We may use our Users’ feedback to improve our products and services. \n e.To process payments - We may use the information Users provide about themselves when placing an order only to provide service to that order. We do not share this information with outside parties except to the extent necessary to provide the service.\n f.To run a promotion, contest, survey or other Site features - To send Users the information they have agreed to receive about topics we think will be of interest to them. \n g.To send periodic emails - We may use the email addresses to send Users information and updates pertaining to their order. It may also be used to respond to their inquiries, questions, and/or other requests. If Users decide to opt-in to our mailing list, they will receive emails that may include company news, updates, related product or service information, etc. If at any time a User would like to unsubscribe from receiving future emails, we include detailed unsubscribe instructions at the bottom of each email or User may contact us via our Site.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n\nChildren under 13 Policy",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n We understand that privacy of children is of utmost importance and therefore, transportdesk.in does not take any personally identifiable information from children below 13 years of age, unless and until such information is shared with parental guidance/consent. On coming to know that any child below the age of 13 has shared personally identifiable information on our site without parental guidance/consent, we reserve the right to delete such information.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n \nDisclaimer and Non-liability from Public Disclosures",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\nAny personal information disclosed by the user on the public message boards of transportdesk.in, by way of comments section, feedback column, message boards can be seen by others and hence, users are advised discretion while disclosing any such information on such sections, and restrain from disclosing personal information. Transportdesk.in is not liable for any such disclosures made by you. \n Any communication or queries between you and any expert from transportdesk.in will not be confidential and transportdesk.in shall have full access to such communication \n Transportdesk.in is not responsible or liable for any personal disclosures made to any linked websites from transportdesk.in.\n We shall send you a welcome note and request you to register using your personal details. We shall use your personal information to send emails, messages or notices regarding our services and also to inform you of any other products or services available from transportdesk.in.\n Transportdesk.in also reserves the right to contact you on the contact details as mentioned by you in your personal information to get feedback from you about our services and we may also conduct surveys regarding this. Your information provided to us will never be shared with any third party unless such third parties are instrumental in performing, some part of our services rendered to you. All such third parties shall maintain confidentiality with respect to this.\n Your personal information like religion, political affiliation, race, etc. will not be disclosed by transportdesk.in without your express consent. Transportdesk.in does not collect such information.\n Transportdesk.in may maintain a record of the websites you visit while using our services in order to track your interest of service and to use it as customized content and advertising within transportdesk.in.\n Your personal information shall be disclosed by transportdesk.in if required by law enforcing agencies to comply with legal procedures in the website or to protect the rights of transportdesk.in or to protect the rights and for personal safety of the users of transportdesk.in.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),

                    ),
                    TextSpan(
                      text: "\n \nUses of Cookies",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\nA cookie is a small file which asks permission to be placed on your mobile’s hard drive. Once you agree, the file is added and the cookie helps to improve quality of service. We may add cookies to your computer in order to uniquely identify your browser and improve the quality of our service. We might enable some of our business partners to use cookies in conjunction with your use of the Site. We have no access to or control over the use of these cookies. These cookies collect information about your use of the Site. You can choose to disable or selectively turn off our cookies or third-party cookies in your browser settings. However, this can affect how you are able to interact with our site as well as other websites.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n \nSecurity of Personal Data",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n \nAny information or passwords that you use to access the transportdesk.in website or mobile application shall be protected from any unauthorized use or hacking. You shall not disclose your password details to any third party and shall notify transportdesk.in, in case of any such unauthorized use.Transportdesk.in has put in suitable physical, electronic and managerial procedures to safeguard and secure the information collected online. Transportdesk.in shall keep your personal information confidential and secured from unauthorized access. Personal information such as credit card number, mobile no. etc., can be transmitted to other websites also, hence, it is protected by encryption, like the Secure Socket Layer (SSL) protocol.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n \nModifications to the Privacy Policy:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n \nTransportdesk.in shall from time to time make changes and updates to these Privacy Policy statements, according to the company or customer feedback or other latest requirements arising. When we do we shall send you an email. Nevertheless, you are expected to view this statement periodically to be aware of any such latest updates, to stay informed about how we are helping to protect the personal information we collect. You acknowledge and agree that it is your responsibility to review this privacy policy periodically and become aware of modifications.\n Please contact us for further information and keep us informed of your suggestions and feedback.\n If you find any discrepancies or have any grievances in relation to the collection, storage, use, disclosure and transfer of Your Personal Information under this Policy or any terms of transportdesk.in Terms of Use, Privacy Policy, etc., please contact the following: \n Shivam , the designated grievance officer under Information Technology Act, 2000 E-mail: support@transportdesk.in .\n The Grievance Officer shall redress the grievances or the provider of information expeditiously but within one month ' from the date of receipt of grievance.",
                     style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
