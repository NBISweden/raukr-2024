# Raukr 2024 • Workshop Website  ![](https://zenodo.org/badge/DOI/10.5281/zenodo.15388710.svg)
**NBIS Summer School • Advanced R for Bioinformatics**

## Environment

To edit, preview and render documents, you need one or more of the following requirements:

- You must use [Quarto\>=1.4.5](https://quarto.org/docs/download/)
- If using RStudio, use [v2023.12.0 or newer](https://posit.co/download/rstudio-desktop/)
- [VSCode](https://arinbasu.medium.com/why-quarto-with-vscode-is-a-great-data-science-tool-f0a259d28702) is a good alternative to RStudio for quarto documents
- You need to install the R packages necessary for your topic/document

:warning: Be wary of using the visual editor! It may mess up the code formatting.

## Adding/Modifying topics

- Fork the repository and clone locally and create a branch
- Keep the topic name simple, preferably one word
- To add a **topic**, create
  - **slides/topic/index.qmd**
  - **labs/topic/index.qmd**
  - The YAML metadata should minimally look like this:

    ```         
    ---
    title: "Topic"
    author: "Author"
    description: "This topic covers this and that."
    format: html
    ---
    ```

- `format` must be `html` for reports and `revealjs` for presentations
- For assets relating to the document (figures, files etc), create an **assets** folder
  - **slides/topic/assets/**
  - **labs/topic/assets/**

:bulb: The document can be live previewed to view changes. Preview is automatically updated on saving the document. Sometimes, the preview can look a bit wonky, in which case, cancel and rerun.

- To preview, run in terminal
  - `quarto preview slides/topic/index.qmd`
  - `quarto preview`
  - Saving the file updates the preview

To preview from inside docker: `quarto preview labs/topic/index.qmd --host 0.0.0.0 --port 4200 --no-browser`

:bulb: The document is rendered to the specified output format in the output directory.

- To render, run in terminal
  - `quarto render slides/topic/index.qmd`
  - `quarto render labs/topic/index.qmd`
  - Rendered files are written to **/docs**
  - To view in browser, open
    - **docs/slides/topic/index.html**
    - **docs/labs/topic/index.html**
    
:warning: Do not run `quarto render` as it will remove everything from **docs/** and attempt to render all the files. This might overwrite someone else's materials and also break since you won't have their R packages installed. So, only render your files.

- Finally commit changes (both source files and rendered files)

```
git stage .
git commit -m "Added topic"
```

- Push changes to your fork and send a pull request

### Docker

A docker container is available for rendering quarto documents and to run RStudio server.

:warning: ~11GB

```
docker pull --platform=linux/amd64 ghcr.io/nbisweden/workshop-raukr:latest
```

**Render qmd**

- For non-interactive use

```
# run in the cloned repo
docker run --platform=linux/amd64 --rm -u 1000:1000 -v ${PWD}:/home/rstudio/raukr ghcr.io/nbisweden/workshop-raukr:latest quarto render index.qmd
```

**Run RStudio server**

- To develop or interactively work with notebooks

```
# run in the cloned repo
docker run --platform=linux/amd64 -e PASSWORD=raukr -p 8787:8787  -p 4200:4200 -v ${PWD}:/home/rstudio/raukr ghcr.io/nbisweden/workshop-raukr:latest
```

In browser, go to [http://localhost:8787/](http://localhost:8787/). Use following credentials:

> username: rstudio  
> password: raukr

On adding new packages, see below.

**Updating docker**

If new packages are added/required, then they need to be added to the docker image as well. It is assumed that you are working in the container. Add packages as you normally would. Once your new materials and new packages are finalized, follow the steps below.

- Update the `renv.lock` file. You need to run this in R in the container and in the root of the repo. This will add your new packages to `renv.lock`. Pay attention to what is changed. If it looks ok, go forward.

```
renv::snapshot(type="all")
```

- Rebuild the container with the new packages. Run this in a local terminal in the root of the repo. **Increment the version number as needed.**

```
docker build --platform=linux/amd64 -t ghcr.io/nbisweden/workshop-raukr:1.4 -t ghcr.io/nbisweden/workshop-raukr:latest --file dockerfile .
```

- Push image back to repository

```
# login if needed
# echo "personalaccesstoken" | docker login ghcr.io -u githubusername --password-stdin

docker push ghcr.io/nbisweden/workshop-raukr:1.4
docker push ghcr.io/nbisweden/workshop-raukr:latest
```

## Convert HTML slides to PDF

```
docker run --platform=linux/amd64 -v $PWD:/work astefanutti/decktape url-to-slide.html /work/output.pdf
```

## Tips & Conventions

- For compute heavy steps, save intermediates and read them in
- Be mindful of the size of files
  - Store large data files elsewhere (dropbox, google drive etc) and link them
  - If you have images that are more than a few hundred KB in size, scale them down to about 600px-800px and [compress](https://compressjpeg.com/) them
- Use simple topic labels and do not make them needlessly complex
- The qmd files must be in the correct location when rendering/previewing else metadata from config is not used. 
- Declare R packages at the beginning of every qmd document
- qmd files must have a format defined, either **format: html** or **format: revealjs**
- Make a note of the default **execute** settings in `_quarto.yml`. This applies to all documents. You can override this by copying the code below to the yaml part of your document and modifying it.

  ```
  execute:
    eval: true
    echo: false
  ```
  
- Use level 2 heading (##) as the highest level heading
- Bullet points are defined by `-`
- Define options in code chunks using `#|` like `#| echo: true`
- Adjusting dimension of images `![Caption](path/to/image.jpg){width="50%"}`
- Divs are defined using `:::` and classes are defined using `{.class}`
  - Example of a class on a div
  
  ```
  ::: {.callout-note}
  content
  :::
  ```
- Example of a class on a span `[Content]{.class}`
- Columns are defined as such

```
:::: {.columns}
::: {.column width="50%"}
Contents
:::
::: {.column width="50%"}
Contents
:::
::::
```

- Remember to spell-check your document
  - Language used is en-us

- To view a demo report, click [here](https://nbisweden.github.io/raukr-2024/labs/demo/)

### RevealJS

These are slide specific info. Comparisons here are to xaringan used previously for RaukR.

- Slides are defined by `##` rather than `---`
- Manual increment is defined by `. . .` rather than `--`
- Horizontal rule is defined by `---` rather than `***`
- Presenter notes are defined by `:::{.notes} content :::` rather than `???`
- For small notes in the bottom of the slide, you can use

```
::: {.aside}
Contents
:::
```

- If content overflows the slide in vertical direction, add class `.scrollable`

```
::: scrollable
content
:::
```

- To view a demo presentation, click [here](https://nbisweden.github.io/raukr-2024/slides/demo/) 
