using Common.Models;
using Microsoft.SharePoint.Client;
using Microsoft.SharePoint.Client.Taxonomy;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common.Helpers
{
    public class OrderListHelper
    {
        public static List<Order> GetAllOrders(ClientContext ctx)
        {
            CamlQuery camlQuery = new CamlQuery();
            camlQuery.ViewXml =
                   @"<View>  
                            <Query> 
                               <OrderBy>
                                    <FieldRef Name='Created' Ascending='FALSE' />
                                </OrderBy> 
                            </Query> 
                             <ViewFields>
                                <FieldRef Name='SW_AmountMoney' />
                                <FieldRef Name='SW_Customer' />
                                <FieldRef Name='ID' />
                                <FieldRef Name='Created' />
                                <FieldRef Name='SW_TaxProduct' />
                            </ViewFields> 
                            <RowLimit>5</RowLimit> 
                      </View>";
            List orderList = ctx.Web.GetListByTitle("Customer Orders");
            ListItemCollection listCollection = orderList.GetItems(camlQuery);
            ctx.Load(listCollection);
            ctx.ExecuteQuery();

            List<Order> ordersToReturn = new List<Order>();
            foreach (ListItem item in listCollection)
            {
                Order orderTemp = new Order();
                orderTemp.Amount = int.Parse(item["SW_AmountMoney"].ToString());
                orderTemp.DateCreated = (DateTime)item["Created"];
                orderTemp.CustomerName = (item["SW_Customer"] as FieldLookupValue).LookupValue;
                orderTemp.Customer = (item["SW_Customer"] as FieldLookupValue).LookupId;
                orderTemp.Products = new List<string>();
                foreach (TaxonomyFieldValue product in item["SW_TaxProduct"] as TaxonomyFieldValueCollection)
                {
                    if (product.Label != null)
                    {
                        orderTemp.Products.Add(product.Label);
                    }
                }
                ordersToReturn.Add(orderTemp);
            }
            return ordersToReturn;
        }

        public static ListItemCollection GetOrderList(int ListItemId, ClientContext ctx)
        {
          
               CamlQuery camlQuery = new CamlQuery();
            camlQuery.ViewXml = $@"
                <View>
                <Query>
                    <OrderBy>
                    <FieldRef Name='Created' Ascending='FALSE' />
                     </OrderBy>
                <Where>
                <Eq>
                <FieldRef Name='SW_Customer' LookupId='True' />
                <Value Type='Lookup'>{ListItemId}</Value>
                 </Eq>
                </Where>
                </Query>
                 <ViewFields>
                      <FieldRef Name='Created' />
                      <FieldRef Name='SW_TaxProduct' />
                      <FieldRef Name='SW_AmountMoney' />
                   </ViewFields>
                </View>";

            List orderList = ctx.Web.GetListByTitle("Customer Orders");
            ListItemCollection listcollection = orderList.GetItems(camlQuery);
            ctx.Load(listcollection);
            ctx.ExecuteQuery();

            return listcollection;
        }

        public static TermCollection GetTaxonomyTermSet(ClientContext ctx)
        {
            TermStore store = ctx.Site.GetDefaultSiteCollectionTermStore();
            TermGroup group = store.GetTermGroupByName("Luis");
            TermSet termSet = group.TermSets.GetByName("Products");
            TermCollection TermCollection = termSet.Terms;
            ctx.Load(TermCollection);
            ctx.ExecuteQuery();

            return TermCollection;
        }
        public static void CreateNewOrder(ClientContext ctx, Order order)
        {
            List list = ctx.Web.GetListByTitle("Customer Orders");
            ListItem item = list.AddItem(new ListItemCreationInformation());
            item["SW_Customer"] = order.Customer;
            item["SW_AmountMoney"] = order.Amount;
            item.Update();

            TermCollection termCollection = OrderListHelper.GetTaxonomyTermSet(ctx);
            List<KeyValuePair<Guid, String>> products_ordered = new List<KeyValuePair<Guid, string>>();

            foreach (var termItem in termCollection)
            {
                foreach (var productItem in order.Products)
                {
                    if (termItem.Name.ToString() == productItem)
                    {
                        products_ordered.Add(new KeyValuePair<Guid, string>(termItem.Id, termItem.Name.ToString()));
                    }
                }
            }
            item.SetTaxonomyFieldValues("{854C4414-A6AB-46B2-A18B-D8BD4C46E960}".ToGuid(), products_ordered);

            ctx.ExecuteQuery();
        }
    }
}
