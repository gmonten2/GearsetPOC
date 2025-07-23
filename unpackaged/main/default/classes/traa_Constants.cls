/**
 * @author          Traction on Demand (Traction TRAA Package)
 * @description     Constants file for the Admissions Liftoff Package
 */
public class traa_Constants {

    public static final String COMMUNITY_NAME = 'admissionsliftoff';
    public static final String LEAD_COMPANY_NAME = 'Individual';
    public static final String ADMIN_ACCOUNT_NAME = 'Administrative Account';

    //Object Name
    public static final String ST_APPLICATIONS = 'hed__Application__c';
    public static final String ST_APPLICATION_TEMPLATE = 'traa_Application_Template__c';
    public static final String RT_ACADEMIC_APPLICATION = 'Academic Application';
    public static final String RT_EDA_APPLICATION = 'EDA Application';

    //Record types
    public static final String RT_ACADEMIC_PROGRAM = 'Academic_Program';
    public static final String RT_APPLICATION_TEMPLATE = 'Application_Template';

    //picklist values
    public static final String ACCOUNT_DECISION_STAGE_ROLLING = 'Rolling';
    public static final String ACCOUNT_DECISION_STAGE_UPDATE_ON_PUBLISH_DATE = 'Update on Publish Decision Date';

    //error messages
    public static final String ERROR_APPLICATION_TEMPLATE_PAGE_NAME = 'Please fill all the Page Names in sequence.';

    //File Component Status
    public static final String UPLOAD_REQUIRED = 'Upload Required';
    public static final String FILE_UPLOADED = 'File Uploaded';
    public static final String REQUIRED = 'Required';
    public static final String OPTIONAL = 'Optional';

    //Drill Down Component
    public static final String WITHDRAWN = 'Withdrawn';
    public static final String APPLICATION_WITHDRAWN = 'Application Withdrawn';
    public static final String WITHDRAWL_REASON = 'Withdraw Reason should not be blank';
    public static final String FETCH_APP = 'Could not fetch the Application';
    public static final String UPLOAD_ERROR = 'There was an Error in updating the document. Please contact your System Administrator';

    //Opportunity
    public static final String STAGE_NAME_STALE = 'Stale';
    public static final String DECLINED_REASON_OTHER = 'Other';
    public static final String DECLINED_NOTES = 'Application deadline passed without an application';
}