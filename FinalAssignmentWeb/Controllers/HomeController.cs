using Common.Helpers;
using Microsoft.SharePoint.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FinalAssignmentWeb.Controllers
{
    public class HomeController : Controller
    {
        // GET: HOME
        [SharePointContextFilter]
        public ActionResult Index(string SPHostUrl)
        {
            User spUser = null;
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var clientContext = spContext.CreateUserClientContextForSPHost())
            {
                if (clientContext != null)
                {
                    spUser = clientContext.Web.CurrentUser;
                    clientContext.Load(spUser, user => user.Title);
                    clientContext.ExecuteQuery();
                    ViewBag.UserName = spUser.Title;
                    ViewBag.SPHostUrl = SPHostUrl;
                }
            }
            return View();
        }


        [HttpPost]
        public ActionResult AddorRemoveCustomAction(string custactionType, string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                Uri appUrl = Request.Url;
                SetupHelpers.AddorRemoveCustomAction(ctx, appUrl, custactionType);
            }
            //return RedirectToAction("Index");
            return RedirectToAction("Index", new { SPHostUrl = SPHostUrl });
        }

    }
}
