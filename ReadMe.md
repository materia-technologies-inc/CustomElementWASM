# ReadMe

## Prerequisites
Before building and running this project, ensure you have the following prerequisites installed on your machine:
- [.NET 10 SDK RC2](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)
- [Node.js (version 16 or later)](https://nodejs.org/)
- [pnpm package manager](https://pnpm.io/installation) (You can install it globally using npm: `npm install -g pnpm`)
- [deno](https://deno.land/#installation) (You can install it using the command: `curl -fsSL https://deno.land/install.sh | sh`)

## Building and Running the Project

To build and run this project, follow these steps:
1. **Clone the Repository**: Start by cloning the repository to your local machine using the following command:
   ```
   git clone https://github.com/materia-technologies-inc/CustomElementWASM.git
   ```
2. Using a powershell prompt, navigate to the solution directory:
   ```
   cd CustomElementWASM
   ``` 
3. Do an install of the npm packages:
   ```
   pnpm install
   ```
4. Run the following command to build the project:
   ```
   pnpm build
   ``` 
5. Run the following command to run the project:
   ```
   pnpm dev
   ``` 
6. In a browser, navigate to `http://localhost:7305` to see the project in action.
 
## Demonstrating RC2 Publish issue

- In RC2, the published custom element is missing many _framework files.

- To demonstrate this, switch to the `rc2-publish` branch:
   ```
   git checkout rc2-publish
   ```
   Then follow the build and run steps above. You will notice that the custom element fails to load due to the missing _framework content.

## Demonstrating RC1/RC2 BlazorWebassembly.js issue

- In RC1 & RC2, the generated `blazor.webassembly.{version}.js` apparently has a hardcoded reference to `dotnet.js`, which leads to failure when deploying the custom element.

- To demonstrate this, switch to the `rc1rc2-hard-code` branch:
   ```
   git checkout rc1rc2-hard-code
   ```
   Then follow the build and run steps above. You will notice that the custom element fails to load due to the hardcoded reference. In broser dev tools just look at the network tab and you will see a failure loading dotnet.js.

### Documentation Needs a Boost

The only documentation available for creating Blazor based custom elements is the official Microsoft documentation. It is sparse on details and does not really give enough guidance to actually deploy
a Blazor WASM custom element. This is of course subjective, but having gone through the process of trial and error to get this working, I believe that more detailed documentation would be very helpful to others trying to do the same thing.

I am referring to one page in particular: [js-spa-framework](https://learn.microsoft.com/en-us/aspnet/core/blazor/components/js-spa-frameworks?view=aspnetcore-10.0&preserve-view=true)

- Concrete example 1: in the section 'Angular sample apps' the apps are welcome but as .Net 7 apps expecting someone to
migrate them to .Net 10 is a big ask. It would be much better to have .Net 10 sample apps. So much has changed
that the .Net 7 apps are not very helpful for someone trying to do this in .Net 10.
- Concrete example 2: in the section 'Blazor WebAssembly registration' it would be more clear to
to show the actual code to register the custom element, rather than the multiple snippets.
Add the narrative about each snippet after the complete example.
```
using BlazorSample.Pages;

using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

// register the counter component as a custom element
builder.RootComponents.RegisterCustomElement<Counter>("my-counter");

await builder.Build().RunAsync();
```
- Concrete example 3: There is no section 'Blazor WebAssembly build'. Presuming it is obvious that the
path to success is to use the
`dotnet publish -c Release` command is used to build the Blazor WASM custom element is a bit much.
- Opinions all, but I really think that more detailed documentation would be very helpful to others trying to create Blazor based custom elements. The emphasis might be best placed on current sample apps.