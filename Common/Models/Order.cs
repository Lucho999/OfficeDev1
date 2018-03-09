using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common.Models
{
    public class Order
    {
        public int Customer { get; set; } // ListItemId
        public string CustomerName { get; set; }
        public int Amount { get; set; }
        public List<string> Products { get; set; }
        public DateTime DateCreated { get; set; }

    }
}
