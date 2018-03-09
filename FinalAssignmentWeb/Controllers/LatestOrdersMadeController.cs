using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Common.Helpers;
using Common.Models;
using Microsoft.SharePoint.Client;

namespace FinalAssignmentWeb.Controllers
{
    public class LatestOrdersMadeController : Controller
    {
        [SharePointContextFilter]
        public ActionResult Index(string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                if (ctx != null)
                {
                    List<Order> listOfOrders = OrderListHelper.GetAllOrders(ctx);
                    ViewBag.SPHostUrl = SPHostUrl;
                    return View(listOfOrders);
                }
            }
            return View();
        }
    }
}
