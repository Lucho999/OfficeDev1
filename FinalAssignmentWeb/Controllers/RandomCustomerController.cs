using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Common.Helpers;
using Common.Models;

namespace FinalAssignmentWeb.Controllers
{
    public class RandomCustomerController : Controller
    {
        [SharePointContextFilter]
        public ActionResult Index(string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                if (ctx != null)
                {
                    ViewBag.SPHostUrl = SPHostUrl;
                    return View();
                }
            }
            return View();
        }
        [HttpPost]
        public ActionResult RandomCustomer(string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                if (ctx != null)
                {
                    Customer customerToReturn = CustomerItemHelper.ReturnRandomCustomer(CustomerItemHelper.GetCustomerWithoutOrder(ctx), ctx);
                    if (customerToReturn!= null)
                    {
                        return RedirectToAction("Index", "CustomerCard", new { ListItemId = customerToReturn.Id, SPHostUrl = SPHostUrl });

                    }
                }
            }
            return View("NoRandomCustomer");
        }
    }
}
