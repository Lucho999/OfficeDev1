using Microsoft.SharePoint.Client;
using OfficeDevPnP.Core.Framework.Provisioning.Model;
using OfficeDevPnP.Core.Framework.Provisioning.Providers.Xml;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common.Helpers
{
    public class SetupHelpers
    {
        public static void UninstallCleanUp(ClientContext ctx)
        {
            CleanUpRemoveFields(ctx, "_Photo");
            CleanUpRemoveFields(ctx, "WorkAddress");
            CleanUpRemoveFields(ctx, "FullName");
            CleanUpRemoveFields(ctx, "WorkPhone");
            CleanUpRemoveFields(ctx, "CellPhone");
            CleanUpRemoveFields(ctx, "EMail");

            CleanUpRemoveContentTypes(ctx, "");

            CleanUpRemoveList(ctx, "Customer List");
            CleanUpRemoveList(ctx, "Customer Orders");

        }
        public static void FixDefaultView(ClientContext ctx)
        {
            // For customer list
            List list=  ctx.Web.GetListByTitle("Customer List");
            ctx.Load(list.DefaultView);
            ctx.ExecuteQuery();
            // add internal names
            list.DefaultView.ViewFields.Add("FullName");
            list.DefaultView.ViewFields.Add("WorkAddress");
            list.DefaultView.ViewFields.Add("_Photo");
            list.DefaultView.ViewFields.Add("WorkPhone");
            list.DefaultView.ViewFields.Add("CellPhone");
            list.DefaultView.ViewFields.Add("EMail");
            list.DefaultView.ViewFields.Add("SW_LastContacted");
            list.DefaultView.ViewFields.Add("SW_LastOrderMade");

            //// For Order list
            //List list = ctx.Web.GetListByTitle("Customer Orders");
            //ctx.Load(list.DefaultView);
            //ctx.ExecuteQuery();
            //// add internal names
            //list.DefaultView.ViewFields.RemoveAll();
            //list.DefaultView.ViewFields.Add("SW_Customer");
            //list.DefaultView.ViewFields.Add("SW_TaxProduct");
            //list.DefaultView.ViewFields.Add("SW_AmountMoney");

            list.DefaultView.Update();
            ctx.ExecuteQuery();

        }

        
        public static void CleanUpRemoveList(ClientContext ctx, string listName)
        {
            if (ctx.Web.ListExists(listName))
            {
                ctx.Web.GetListByTitle(listName).DeleteObject();
                ctx.ExecuteQuery();
            }
        }
        

        public static void CleanUpRemoveFields(ClientContext ctx, string fieldName)
        {
            if (ctx.Web.FieldExistsByName(fieldName))
            {
                ctx.Web.GetFieldByInternalName(fieldName).DeleteObject();
                ctx.ExecuteQuery();
            }
        }

        public static void CleanUpRemoveContentTypes(ClientContext ctx, string Contenttype)
        {
            if (ctx.Web.ContentTypeExistsByName(Contenttype))
            {
                ctx.Web.GetFieldByInternalName(Contenttype).DeleteObject();
                ctx.ExecuteQuery();
            }
        }
      

        // tror inte detta kommmer funka
        public static void RemoveAllFieldsFromGroup(ClientContext ctx, string fieldGroup)
        {
            if (ctx.Web.GroupExists(fieldGroup))
            {
                ctx.Web.RemoveGroup(fieldGroup);
            }
        }


        public static void RunXmlFiles(ClientContext ctx)
        {
            //To run XML files change the template name and the path of the file.
            XMLFileSystemTemplateProvider provider = new XMLFileSystemTemplateProvider(@"C:\Users\lucho\source\repos\OfficeDev1\FinalAssignment\Common\XML", "");
            string templateName = "assignment.xml";
            ProvisioningTemplate template = provider.GetTemplate(templateName);
            ctx.Web.ApplyProvisioningTemplate(template);
        }

        public static void AddorRemoveCustomAction(ClientContext ctx, Uri appUrl, string custactionType)
        {
            List list = ctx.Web.GetListByTitle("Customer List");
            if (custactionType == "Remove")
            {
                ctx.Load(list.UserCustomActions);
                ctx.ExecuteQuery();
                int customActions = list.UserCustomActions.Count();
                for (int i = customActions; i > 0; i--)
                {
                    if (list.UserCustomActions[i-1].Name == "CustomName")
                    {
                        list.UserCustomActions[i-1].DeleteObject();
                        ctx.ExecuteQuery();
                    }
                }
               
            }
            else
            {
                UserCustomAction action = list.UserCustomActions.Add();
                action.Title = "Go to Customer Card";
                action.Name = "CustomName";
                action.Url = appUrl.Scheme + "://" + appUrl.Authority + "/CustomerCard/Index" + appUrl.Query + "&ListId={ListId}&ListItemId={ItemId}";
                action.Location = "EditControlBlock";
                action.Sequence = 1;
                action.Update();
                ctx.ExecuteQuery();
            }
        }
    }
}
