using Common.Models;
using Microsoft.SharePoint.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common.Helpers
{
    public class CustomerItemHelper
    {
        public static ListItem GetListItem(ClientContext ctx, int itemId)
        {
            List list = ctx.Web.GetListByTitle("Customer List");
            ListItem item = list.GetItemById(itemId);
            ctx.Load(item);
            ctx.ExecuteQuery();
            return item;
        }

        public static void UpdateLastOrderMade(ClientContext ctx, int itemId)
        {
            ListItem item = GetListItem(ctx, itemId);
            item["SW_LastOrderMade"] = DateTime.Now;
            item.Update();
            ctx.ExecuteQuery();
        }
        public static List<Customer> GetCustomerWithoutOrder(ClientContext ctx)
        {
            List<Customer> customerList = ReturnCustomerList(ctx);
            List<Customer> customerListToReturn = new List<Customer>();
            List<Order> orderList=  OrderListHelper.GetAllOrders(ctx);

            foreach (Customer item in customerList)
            {
                if (!orderList.Any(x => x.CustomerName == item.Title))
                {
                    customerListToReturn.Add(GetCustomerFromSharepoint(item.Id, ctx));
                    
                }
            }
            return customerListToReturn;
        }

        public static Customer ReturnRandomCustomer(List<Customer> customerList, ClientContext ctx)
        {
            int listPosition;
            Customer customerToReturn = new Customer();
            Random r = new Random();
            listPosition = r.Next(0, (customerList.Count));
            customerToReturn = customerList[listPosition];
            return customerToReturn;
        }

        public static List<Customer> ReturnCustomerList(ClientContext ctx)
        {
            List list = ctx.Web.GetListByTitle("Customer List");
            CamlQuery query = new CamlQuery();
                //< RowLimit > 3 </ RowLimit >
            query.ViewXml =
              @"<View>  
                    <Query> 
                        <OrderBy><FieldRef Name='Created'  Ascending='FALSE'/></OrderBy> 
                     </Query> 
                    <ViewFields>
                        <FieldRef Name='Title' />
                        <FieldRef Name='_Photo' />
                        <FieldRef Name='EMail' />
                        <FieldRef Name='FullName' />
                        <FieldRef Name='ID' />
                        <FieldRef Name='WorkAddress' />
                        <FieldRef Name='CellPhone' />
                    </ViewFields> 
               </View>";
            ListItemCollection items =  list.GetItems(query);
            ctx.Load(items);
            ctx.ExecuteQuery();

            List<Customer> customers = new List<Customer>();
            foreach (ListItem item in items)
            {
                Customer customer = GetCustomerFromSharepoint(item.Id, ctx);
                customers.Add(customer);
            }
            return customers;
        }

      
        public static Customer GetCustomerFromSharepoint(int itemId, ClientContext ctx)
        {
            ListItem item = GetListItem(ctx, itemId);
            Customer customer = new Customer();

            customer.Id = itemId;
            customer.Title = item["Title"].ToString();
            customer.Adress = item["WorkAddress"].ToString();
            customer.FullName = item["FullName"].ToString();
            customer.WorkPhone = item["WorkPhone"].ToString();
            customer.CellPhone = item["CellPhone"].ToString();
            customer.Email = item["EMail"].ToString();
            customer.LastContacted = DateTime.Parse(item["SW_LastContacted"].ToString());
            customer.LastOrderMade = DateTime.Parse(item["SW_LastOrderMade"].ToString());

            string strurl = ((FieldUrlValue)(item["_Photo"])).Url;
            customer.Photo = strurl.ToString();

            return customer;
        }

        public static void SaveChangesToCustomer(int itemId, Customer customer, ClientContext ctx)
        {
            ListItem item = GetListItem(ctx, itemId);

            item["WorkAddress"] = customer.Adress;
            item["FullName"] = customer.FullName;
            item["WorkPhone"] = customer.WorkPhone;
            item["CellPhone"] = customer.CellPhone;
            item["EMail"] = customer.Email;
            item["SW_LastContacted"] = customer.LastContacted;
            item.Update();
            ctx.ExecuteQuery();

        }

        
    }
}
