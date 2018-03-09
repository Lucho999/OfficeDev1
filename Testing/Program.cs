using Microsoft.SharePoint.Client;
using OfficeDevPnP.Core;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Common.Helpers;

namespace Testing
{
    class Program
    {
        static void Main(string[] args)
        {
            string url = "https://folkis2017.sharepoint.com/sites/LuisFinalAssignment";
            // get settings from your app.config file
            string clientId = ConfigurationManager.AppSettings["ClientId"];
            string clientSecret = ConfigurationManager.AppSettings["Secret"];


            AuthenticationManager authManager = new AuthenticationManager();
            using (ClientContext ctx = authManager.GetAppOnlyAuthenticatedContext(url, clientId, clientSecret))
            {

                SetupHelpers.RunXmlFiles(ctx);
                //SetupHelpers.FixDefaultView(ctx);

                Console.WriteLine("Its done..");
                Console.ReadKey();
            }

        }


    }
}
