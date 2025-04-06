export const createPages = async ({ graphql }) => {
  const result = await graphql(`
    {
      allMarkdownRemark(limit: 1000) {
        edges {
          node {
            fileAbsolutePath
            frontmatter {
              thumbnail {
                relativePath
              }
            }
          }
        }
      }
    }
  `);

  console.log(result);
};
