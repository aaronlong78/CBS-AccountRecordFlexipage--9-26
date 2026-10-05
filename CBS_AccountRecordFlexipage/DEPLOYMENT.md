# Deploy CBS Account Record Page

Deploying `manifest/package.xml` creates `CBS_Account_Record_Page` in the target org. It does not activate the page. The Revenue Cloud app default is an `actionOverrides` entry on that app, and this package does not include the app.

After the package deploy succeeds, assign the page as the Account desktop app default for the Revenue Cloud Lightning app in the target org.

## 1. Deploy the package

Deploy `manifest/package.xml` first, so `CBS_Account_Record_Page` exists before the assignment.

## 2. Resolve the Revenue Cloud app in the target org

Look up the Revenue Cloud Lightning app in the target org (App Manager, or `AppDefinition` where the label is Revenue Cloud). Retrieve that app from the target as `standard__<DeveloperName>`.

Do not guess the developer name. Do not retrieve the app from the source org.

## 3. Set the Account desktop app default

On the retrieved target app file, add this override:

```xml
<actionOverrides>
    <actionName>View</actionName>
    <content>CBS_Account_Record_Page</content>
    <formFactor>Large</formFactor>
    <skipRecordTypeSelect>false</skipRecordTypeSelect>
    <type>Flexipage</type>
    <pageOrSobjectType>Account</pageOrSobjectType>
</actionOverrides>
```

If an Account + Large `actionOverrides` entry already exists, change its `content` to `CBS_Account_Record_Page`. Do not add a second one.

Leave every other override, tab, and app setting as retrieved from the target.

Do not add a `profile` or `recordType`. Those fields make a narrower assignment instead of the app default. Do not set `formFactor` Small unless the source org's phone assignment is confirmed separately.

## 4. Deploy the app back to the target

Deploy that CustomApplication back to the target org. Do not deploy a full copy of the source org's Revenue Cloud app.

An app-default Flexipage override cannot be removed later through destructive changes. Change it in Lightning App Builder.
