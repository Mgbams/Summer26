/**
 * Dynamic picklist provider for the Industry Focus input.
 *
 * Flow Builder calls this class when an admin configures the Apex action.
 * Runtime Apex still receives a String.
 */
global with sharing class AccountIndustryPicklist extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        for (Schema.PicklistEntry entry : getActiveIndustryEntries()) {
            return new VisualEditor.DataRow(entry.getLabel(), entry.getValue());
        }

        return new VisualEditor.DataRow('No active Account Industry values found', '');
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows rows = new VisualEditor.DynamicPickListRows();
        Boolean hasRows = false;

        for (Schema.PicklistEntry entry : getActiveIndustryEntries()) {
            rows.addRow(new VisualEditor.DataRow(entry.getLabel(), entry.getValue()));
            hasRows = true;
        }

        if (!hasRows) {
            rows.addRow(new VisualEditor.DataRow('No active Account Industry values found', ''));
        }

        return rows;
    }

    private static List<Schema.PicklistEntry> getActiveIndustryEntries() {
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();

        Schema.SObjectField industryField = Schema.SObjectType.Account.fields.getMap().get('Industry');

        if (industryField == null) {
            return activeEntries;
        }

        Schema.DescribeFieldResult describeResult = industryField.getDescribe();

        for (Schema.PicklistEntry entry : describeResult.getPicklistValues()) {
            if (entry.isActive()) {
                activeEntries.add(entry);
            }
        }

        return activeEntries;
    }
}