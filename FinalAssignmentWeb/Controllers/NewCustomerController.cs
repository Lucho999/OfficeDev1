using Common.Helpers;
using Common.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FinalAssignmentWeb.Controllers
{
    public class NewCustomerController : Controller
    {
        [SharePointContextFilter]
        public ActionResult Index(string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                if (ctx != null)
                {
                    List<Customer> customerModel =CustomerItemHelper.ReturnCustomerList(ctx);
                    ViewBag.SPHostUrl = SPHostUrl;
                    return View(customerModel);
                }
            }
            return View();
        }
    }
}
