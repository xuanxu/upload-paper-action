# Open Journals :: Upload paper

This action uploads a paper pdf file to its own branch in the corresponding Open Journal's papers repository

## Usage

Usually this action is used as a step in a workflow that also includes other steps for generating the pdf.

### Inputs

The action accepts the following inputs:

- **pdf_path**: Required. The path to the pdf file to upload.
- **papers_repo**: Required. The repository containing the published and submitted papers in `owner/reponame` format.
- **issue_id**: Required. The issue number of the submission of the paper.
- **branch_prefix**: Optional. The prefix to add to the name of the created branches.
- **bot_token**: Optional. The GitHub access token to be used to upload files. Default: `ENV['GH_ACCESS_TOKEN']`

### Outputs

If the action runs successfully it generates two outpus:

- **html_url**: The HTML URL for the uploaded file
- **download_url**: The direct download URL for the uploaded file

### Example

Use it adding it as a step in a workflow `.yml` file in your repo's `.github/workflows/` directory and passing your custom input values (here's an example showing how to pass input values from diferent sources: workflow inputs, secrets or directly).

````yaml
on:
  workflow_dispatch:
   inputs:
      issue_id:
        description: 'The issue number of the submission'
jobs:
  processing:
    runs-on: ubuntu-latest
    steps:
      - name: Upload file to papers repo
        uses: xuanxu/upload-paper-action@main
        with:
          papers_repo: myorg/myjournal-papers
          branch_prefix: myjournal
          issue_id: ${{ github.event.inputs.issue_id }}
          pdf_path: docs/paper.pdf
          bot_token: ${{ secrets.BOT_ACCESS_TOKEN }}
```
