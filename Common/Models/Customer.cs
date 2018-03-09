using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Common.Models
{
    public class Customer
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Adress { get; set; }
        public string FullName { get; set; }
        public string WorkPhone { get; set; }
        public string CellPhone { get; set; }
        public string Email { get; set; }
        public string Photo { get; set; }
        public DateTime LastContacted { get; set; }
        public DateTime LastOrderMade { get; set; }
    }
}