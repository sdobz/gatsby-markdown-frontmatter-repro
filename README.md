# Intent

While working on my blog I discovered an issue with querying image files in markdown frontmatter

This is an attempt to recreate the issue

# Actual reproduction

Start with my blog. Delete as many things as possible to retain the bug

Discovered the issue was with "thumbnail" and "parent" in frontmatter

# Minimal reproduction steps

1. npm init gatsby
2. Enable markdown plugin
3. https://www.gatsbyjs.com/docs/how-to/images-and-media/working-with-images-in-markdown/
4. Create a markdown page with "parent" in the frontmatter and "thumbnail" pointing to a file

```bash
yarn develop

...
success building schema - 0.213s
{
  errors: [
    TypeError: ids.push is not a function
        at LocalNodeModel.findRootNodeAncestor
(/home/vkhougaz/projects/gatsby-node-fix/node_modules/gatsby/dist/schema/node-model.js:439:11)
        at ContextualNodeModel.findRootNodeAncestor
(/home/vkhougaz/projects/gatsby-node-fix/node_modules/gatsby/dist/schema/node-model.js:568:27)
        at fileByPathResolver
(/home/vkhougaz/projects/gatsby-node-fix/node_modules/gatsby/dist/schema/resolvers.js:387:46)
        at process.processTicksAndRejections (node:internal/process/task_queues:105:5)
        at async Promise.all (index 0)
        at async Promise.all (index 1)
        at async Promise.all (index 0)
        at async Promise.all (index 0)
        at async Promise.all (index 0) {
      path: [Array],
      locations: [Array],
      extensions: [Object: null prototype] {}
    }
  ],
  data: [Object: null prototype] {
    allMarkdownRemark: [Object: null prototype] { edges: [Array] }
  }
}
success createPages - 0.029s
...
```

# Diagnosis

While reading `node-model.js` I `console.log`'d ids and noted it was a Set

https://github.com/gatsbyjs/gatsby/blob/4ba965272a87112b1ae805e2d311746ffff56339/packages/gatsby/src/schema/node-model.js#L527

```javascript
  findRootNodeAncestor(obj, predicate = null) {
    let iterations = 0;
    let ids = this._rootNodeMap.get(obj);
    console.log(ids); // DEBUG
    if (!ids) {
      ids = [];
    }
    if (obj !== null && obj !== void 0 && obj.parent) {
      ids.push(obj.parent);
    }
```

```
Set(1) { '1afed4c9-65b6-512d-97ab-5c2f6a7aca3b' }
```

Invesigating `_rootNodeMap` indeed, it is created as a set

https://github.com/gatsbyjs/gatsby/blob/4ba965272a87112b1ae805e2d311746ffff56339/packages/gatsby/src/schema/node-model.js#L979

```javascript
    // don't need to track node itself
    if (!isNode) {
      let nodeIds = rootNodeMap.get(data);
      if (!nodeIds) {
        nodeIds = new Set([nodeId]);
      } else {
        nodeIds.add(nodeId);
      }
      rootNodeMap.set(data, nodeIds);
    }
```

There appears to be a type disparity between ids as a Set (`.add`) and ids as an Array (`.push`)

This code was added in Oct 2022 and includes the type disparity
https://github.com/gatsbyjs/gatsby/commit/696a7ba230fcfc76e99232293cd548c832084c47

# Fix

Update the `findRootNodeAncestor` function to consistently treat nodeIds as a Set

