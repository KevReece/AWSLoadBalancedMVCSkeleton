using Microsoft.Owin;
using Owin;

[assembly: OwinStartup(typeof(ExampleApp.ExampleApp.Startup))]
namespace ExampleApp.ExampleApp
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
        }
    }
}
