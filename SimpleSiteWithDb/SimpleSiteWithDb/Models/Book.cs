using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SimpleSiteWithDb.Models
{
    public class Book
    {
        public int BookId { get; set; }
        public string Name { get; set; }
        public string ISDN { get; set; }

    }
}