using SimpleSiteWithDb.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SimpleSiteWithDb.Controllers
{
    public class BooksController : Controller
    {
        public ActionResult Index()
        {
            using (var db = new BookStoreContext("BookStoreConnectionString"))
            {
                return View(db.Books.ToList());
            } 
        }

        [HttpGet]
        public ActionResult Add()
        {
            Book book = new Book();
            return View(book);
        }

        [HttpPost]
        public ActionResult Add(Book book)
        {
            using (var db = new BookStoreContext("BookStoreConnectionString"))
            {
                db.Books.Add(book);
                db.SaveChanges(); 
            }
            return View(book);
        }
    }
}


