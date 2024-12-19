import { access, exists, existsSync, lstat, lstatSync, mkdirSync, readdirSync, readFile, readFileSync, stat, statfs, Stats, statSync, writeFile, writeFileSync } from 'fs';
import { bundle } from 'luabundle';

const basePath = process.argv[1];
const srcPath = `${basePath}/src`;

const projects = readdirSync(srcPath, { recursive: true }).filter((item) => { if (item.includes("bundleConfig.json")) { return true } });

const baseConfig = JSON.parse(readFileSync('./bundler/baseBundleConfig.json').toString())

projects.forEach((project) => {
    const configPath = `${srcPath}/${project}`;

    if (!statSync(configPath).isFile()) {
        return;
    }

    const config:JSON = JSON.parse(readFileSync(configPath).toString());

    const relativeBaseDirectoryPath:string = config['relativeBaseDirectoryPath'] ?? baseConfig['relativeBaseDirectoryPath']
    const baseProjectPath = `${configPath.slice(0, configPath.indexOf('bundleConfig.json'))}${relativeBaseDirectoryPath}`;

    if(!statSync(baseProjectPath).isDirectory()){
        return;
    }

    const main:string = config['main'] ?? baseConfig['main'];
    const relativeMainPath =  readdirSync(baseProjectPath, { recursive: true }).filter((item) => { if (item.includes(main)) { return true } });
    const mainPath = `${baseProjectPath}${relativeMainPath}`
    
    if(!statSync(mainPath).isFile()){
        return;
    }

    let paths:Array<string> = config['paths'] ?? baseConfig['paths'];
    paths = paths.map((path) => {return `${baseProjectPath}${path}`})

    let bundledLua = bundle(mainPath, {
        paths,
        expressionHandler: (module, expression) => {
            const start = expression.loc!.start;
            console.warn(`WARNING: Non-literal require found in '${module.name}' at ${start.line}:${start.column}`);
        },
    });

    const projectName:string = config['projectName'] ?? baseConfig['projectName'];

    if (!existsSync(`${basePath}/bundler/bundles`)){
        mkdirSync(`${basePath}/bundler/bundles`);
    }

    bundledLua = `local args = {...} ${bundledLua}`

    writeFileSync(`${basePath}/bundler/bundles/${projectName}.lua`, bundledLua)
})
