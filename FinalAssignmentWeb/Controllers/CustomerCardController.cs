using Common.Helpers;
using Common.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FinalAssignmentWeb.Controllers
{
    public class CustomerCardController : Controller
    {
        // GET: CustomerCard
        [HttpGet]
        [SharePointContextFilter]
        public ActionResult Index(int ListItemId, int? ListId, string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);
            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                // ViewBag.IsUpdated = IsUpdated;
                ViewBag.OrderList = OrderListHelper.GetOrderList(ListItemId, ctx);
                Customer customer = CustomerItemHelper.GetCustomerFromSharepoint(ListItemId, ctx);
                ViewBag.CustomerId = ListItemId;
                ViewBag.SPHostUrl = SPHostUrl;
                return View(customer);
            }

        }


       
       [HttpPost]
        public ActionResult SaveChanges(int ListItemId, string SPHostUrl, Customer customer)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);
            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                CustomerItemHelper.SaveChangesToCustomer(ListItemId, customer, ctx);
                return RedirectToAction("Index", new { ListItemId = ListItemId, SPHostUrl = SPHostUrl, IsUpdated = true });
            }
        }

        [SharePointContextFilter]
        public ActionResult NewOrder(int ListItemId)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);

            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                Customer customer = CustomerItemHelper.GetCustomerFromSharepoint(ListItemId, ctx);
                ViewBag.termset = OrderListHelper.GetTaxonomyTermSet(ctx);
                ViewBag.listitem = ListItemId;
                ViewBag.CompanyName = customer.Title;
                return View();
            }
        }

        [HttpPost]
        public ActionResult NewOrder(Order order, string SPHostUrl)
        {
            var spContext = SharePointContextProvider.Current.GetSharePointContext(HttpContext);
            using (var ctx = spContext.CreateUserClientContextForSPHost())
            {
                OrderListHelper.CreateNewOrder(ctx, order);
                CustomerItemHelper.UpdateLastOrderMade(ctx, order.Customer);
            }
            return RedirectToAction("Index", new { ListItemId = order.Customer, SPHostUrl = SPHostUrl });
        }
    }
}
