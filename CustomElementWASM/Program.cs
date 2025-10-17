using CustomElementWASM;

using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

// Add root components to ensure blazor.boot.json is generated
// This is required even for custom-elements-only projects in .NET 10 RC2
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

// register the viewer component as a custom element
builder.RootComponents.RegisterCustomElement<BlazorMarkdigViewer>("blazor-markdig-viewer");

await builder.Build().RunAsync();
