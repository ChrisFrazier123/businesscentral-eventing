# Way We Work
## AL Projects
### Repository Structure
One repository [repo name] holds all Business Central extensions.  Individual extensions live underneath.
```
root/
├─ apps/
│  ├─ app1/
│  ├─ app2/
│  └─ app3/
└─ README.md
```

#### App folder structure
AL-specific folders belong in the app root.  Code files should be under in src directory, organized by namespace.
```
app1/
├─ .alpackages/
├─ .vscode/
├─ docs/
├─ permissions/
├─ src/
│  └─ CF/
│     └─ BI/
|        └─ API/
|           └─ V1/
├─ translations/
├─ app.json
└─ README.md
```

#### File Naming
| File Type      | Pattern |
| ----------- | ----------- |
| Object      | \<ObjectTypeShort>\<ObjectId>.\<ObjectNameShort>.al"|

### Documentation

The **root `README.md`** should provide a high-level overview of the repository, including:

- A list of all extensions contained in the repo  
- A brief description of each extension  
- Links to the extension-specific documentation  

Each **extension’s `README.md`** should contain:

- A concise description of the extension’s purpose and functionality  
- Any technical or architectural details relevant to that specific extension  
- Links to supplemental documentation stored in the extension’s `docs/` folder  

All supporting documentation—such as images, architecture diagrams, additional Markdown files, or extended guides—should be placed in the extension’s dedicated `docs/` folder to maintain a clean and organized repository structure.


### VS Code Extensions
- AL Language extension for Micrsoft Dynamics 365 Business Central
- AZ AL Dev Tools/AL Code Outline
- waldo's CRS AL Language Extension