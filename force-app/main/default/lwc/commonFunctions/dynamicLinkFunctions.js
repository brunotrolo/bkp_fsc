import getObjectIdFromQuery from "@salesforce/apex/DynamicLinkHelper.getObjectIdFromQuery";
import getDynamicLinkByIdentity from "@salesforce/apex/DynamicLinkHelper.getDynamicLinkByIdentity";
import getRecordIdFromDynamicLinkType from "@salesforce/apex/DynamicLinkHelper.getRecordIdFromDynamicLinkType";
import getSiteUrl from "@salesforce/apex/DynamicLinkHelper.getSiteUrl";
import getSetupPageLink from "@salesforce/apex/DynamicLinkHelper.getSetupPageLink";

// Returns the first record from a SOQL result, or throws a clear error when
// the query returned no rows (e.g. the record the dynamic link points to does
// not exist in this org). Prevents an uncaught "Cannot read properties of
// undefined (reading 'Id')" crash from a misconfigured link.
const getFirstRecordOrThrow = (records, dynamicLink) => {
  if (!records || records.length === 0) {
    const linkName = dynamicLink && dynamicLink.Name ? dynamicLink.Name : "";
    throw new Error(
      "No matching record found for link '" +
        linkName +
        "'. Check its object and filter configuration."
    );
  }
  return records[0];
};

const getPageReferenceByDynamicType = async (dynamicLink) => {
  var pageReference;
  switch (dynamicLink.RecordType.DeveloperName) {
    case "NamedPage":
      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: dynamicLink.App_API_Name__c,
          pageRef: {
            type: "standard__namedPage",
            attributes: {
              pageName: dynamicLink.Page_Name__c
            }
          }
        }
      };
      break;
    case "APINamePage":
      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: dynamicLink.App_API_Name__c,
          pageRef: {
            type: "standard__navItemPage",
            attributes: {
              apiName: dynamicLink.Page_Name__c
            }
          }
        }
      };
      break;
    case "AppPage":
      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: dynamicLink.App_API_Name__c
        }
      };
      break;
    case "ObjectPage":
      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: dynamicLink.App_API_Name__c,
          pageRef: {
            type: "standard__objectPage",
            attributes: {
              objectApiName: dynamicLink.Object__c,
              actionName: "list"
            }
          }
        }
      };
      if (dynamicLink.Filter_Name__c) {
        pageReference.attributes.pageRef.state = {
          filterName: dynamicLink.Filter_Name__c
        };
      }
      break;
    case "RecordPage":
      // execute select query and get the id
      const SELECTQUERYRESULT = await getObjectIdFromQuery({
        objectAPIName: dynamicLink.Object__c,
        whereCondition: dynamicLink.Where_Condition__c
      });
      // get the id from the result
      const objectId = getFirstRecordOrThrow(SELECTQUERYRESULT, dynamicLink).Id;

      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: dynamicLink.App_API_Name__c,
          pageRef: {
            type: "standard__recordPage",
            attributes: {
              objectApiName: dynamicLink.Object__c,
              actionName: "view",
              recordId: objectId
            }
          }
        }
      };
      break;
    case "RecordRelationshipPage":
      // execute select query and get the id
      const SELECTRESULT = await getObjectIdFromQuery({
        objectAPIName: dynamicLink.Object__c,
        whereCondition: dynamicLink.Where_Condition__c
      });
      // get the id from the result
      const objectResultId = getFirstRecordOrThrow(
        SELECTRESULT,
        dynamicLink
      ).Id;

      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: dynamicLink.App_API_Name__c,
          pageRef: {
            type: "standard__recordRelationshipPage",
            attributes: {
              objectApiName: dynamicLink.Object__c,
              actionName: "view",
              recordId: objectResultId,
              relationshipApiName: dynamicLink.Relationship_API_Name__c
            }
          }
        }
      };
      break;
    case "WebPage":
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url: dynamicLink.Link__c
        }
      };
      break;
    case "CommunityPage":
      const communityPage = await getRecordIdFromDynamicLinkType({
        dyanmicLinkType: dynamicLink.RecordType.DeveloperName,
        whereCondition: "Name='" + dynamicLink.Site_Name__c + "'"
      });
      let siteUrl = await getSiteUrl({
        networkId: getFirstRecordOrThrow(communityPage, dynamicLink).Id
      });
      if (dynamicLink.Relative_Url__c) {
        siteUrl += dynamicLink.Relative_Url__c;
      }
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url: siteUrl
        }
      };
      break;
    case "InAppDetailsPage":
      pageReference = {
        type: "standard__app",
        attributes: {
          appTarget: "c__Learning_Home",
          pageRef: {
            type: "standard__navItemPage",
            attributes: {
              apiName: "Learning_Application_Details_Page"
            }
          }
        }
      };
      break;
    case "SurveyRecordPage":
      const survey = await getRecordIdFromDynamicLinkType({
        dyanmicLinkType: dynamicLink.RecordType.DeveloperName,
        whereCondition: dynamicLink.Where_Condition__c
      });
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url:
            "/survey/builderApp.app?surveyId=" +
            getFirstRecordOrThrow(survey, dynamicLink).Id
        }
      };
      break;
    case "DPERecordPage":
      const dpeRecord = await getRecordIdFromDynamicLinkType({
        dyanmicLinkType: dynamicLink.RecordType.DeveloperName,
        whereCondition: dynamicLink.Where_Condition__c
      });
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url:
            "/builder_industries_dataprocessingengine/dataProcessingEngine.app?dataProcessingEngineId=" +
            getFirstRecordOrThrow(dpeRecord, dynamicLink).Id
        }
      };
      break;
    case "FlowRecordPage":
      const flowActiveVersion = await getRecordIdFromDynamicLinkType({
        dyanmicLinkType: dynamicLink.RecordType.DeveloperName,
        whereCondition: dynamicLink.Where_Condition__c
      });
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url:
            "/builder_platform_interaction/flowBuilder.app?flowId=" +
            getFirstRecordOrThrow(flowActiveVersion, dynamicLink)
              .ActiveVersionId
        }
      };
      break;
    case "SetupPage":
      const records = await getObjectIdFromQuery({
        objectAPIName: dynamicLink.Setup_Page__c,
        whereCondition: dynamicLink.Where_Condition__c
      });
      const setupPage = await getSetupPageLink({
        objectAPIName: dynamicLink.Setup_Page__c,
        record: getFirstRecordOrThrow(records, dynamicLink).Id
      });

      pageReference = {
        type: "standard__webPage",
        attributes: {
          url: setupPage
        }
      };
      break;
    default:
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url: dynamicLink.Link__c
        }
      };
      break;
  }
  if (dynamicLink.Page__c != null && dynamicLink.Page__c !== undefined) {
    pageReference.attributes.pageRef.state = {
      c__pageId: dynamicLink.Page__c
    };
  }
  return pageReference;
};

const getDynamicLinkByIdentifier = async (identifier) => {
  const SELECTQUERYRESULT = await getDynamicLinkByIdentity({
    identifier: identifier
  });
  return SELECTQUERYRESULT;
};

// Opens a URL in a new browser tab in an LWS-safe way.
// Lightning Web Security blocks window.open() for same-origin URLs
// ("Cannot open same-origin URL in a new browsing context"), so we use a
// programmatic anchor with target="_blank" instead, which LWS permits.
const openUrlInNewTab = (url) => {
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.target = "_blank";
  anchor.rel = "noopener noreferrer";
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
};

const findDynamicLinkIdentifier = (input, middlePosition) => {
  var spacePosition = middlePosition;
  //Check for character which is non-capital alphabet or underscore
  for (
    ;
    ((input.charCodeAt(spacePosition) >= 65 &&
      input.charCodeAt(spacePosition) <= 90) ||
      input.charCodeAt(spacePosition) == 95) != " ";
    spacePosition--
  ) {}

  return input.substring(spacePosition + 1, middlePosition + 8);
};
export {
  getDynamicLinkByIdentifier,
  getPageReferenceByDynamicType,
  findDynamicLinkIdentifier,
  openUrlInNewTab
};