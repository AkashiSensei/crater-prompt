# PR 描述 prompt 文档

请 Agent 根据本文档的描述，代码的修改，对话的上下文以及用户输入的信息来创建一个 GitHub PR 的描述，并使用一个代码框输出生成的 Markdown 格式的双语描述。

以下是格式：

```markdown

首先使用一句话大致描述这个 pr，如果用户给出了进行此修改的原因，那么需要添加在这里。

### 修改

- 使用几个分点描述进行了哪些修改，注意不需要过于的细节，而是需要进行总结，因为 reviewer 能够很方便的看到具体文件的改动
- 如果用户提供了一些细节的想法和设计，你需要思考如何以合适的方式叙述它们
- 分点的名称尽量描述做了什么，例如为前端添加 workflow，实在不好总结时，可以使用前端作为冒号前的分点名称

### 测试

如果有总结性质的内容，或者对所有测试 case 的总体描述或测试环境描述，可以写在这里

- 使用几个分点来描述进行了哪些测试，如果用户没有告诉你进行了哪些测试，那么你需要询问用户

### 其他（可选）

如果有一些特殊的内容需要说明，你需要根据用户说明添加在这里。

---

这里提供上面全部内容的英文翻译

---

这里使用英文给出关联的 ISSUE，可能是解决了某个 ISSUE，也可能只是相关，需要使用 GitHub 能够自动识别的方式列举，方便 GitHub 自动关闭 ISSUE 等。

如果有多个 ISSUE，每行提供一个，不要使用逗号的方式在一行内给出多个，这样 Github 不能自动识别。

```


例如：

```markdown
将各个子仓库的 pre-commit hook 统一到主仓库管理，主仓库负责协调，各子仓库通过 Makefile 的 `pre-commit-check` target 实现各自的检查逻辑。

### 修改

- **主仓库**：创建统一的 `.githook/pre-commit` 钩子和 `Makefile`，根据变更自动调用对应子仓库的检查
- **backend**：移除 `.githook/pre-commit`，在 `Makefile` 中添加 `pre-commit-check` target（执行 lint 和 docs 生成）
- **frontend**：移除 `.husky` 目录、`commitlint.config.cjs` 及相关依赖（husky、commitlint、commitizen），在 `Makefile` 中添加 `pre-commit-check` target（执行 lint 和 lint-staged）
- **storage**：移除 `.githook/pre-commit`，在 `Makefile` 中添加 `pre-commit-check` target（执行 golangci-lint）
- **website**：移除 `scripts/install-git-hooks.mjs` 和 `scripts/pre-commit`，创建 `Makefile` 和 `scripts/check-webp-images.sh`，添加 `pre-commit-check` target（检查新增图片是否为 WebP 格式）

### 测试

- 逐仓库测试钩子脚本是否能够正常工作
- 测试多个仓库同时产生修改的情况下，钩子脚本是否能够正常工作
- 测试没有修改时，钩子脚本是否能够正常输出

### 特别说明

作为开发者，你需要在主仓库使用 `make install-hooks` 来安装钩子脚本。另外需要注意的是，如果您同时修改了 *backend* 和 *storage* 子仓，则脚本有可能因为 Go 版本不一致而无法正常工作。

---

Unify pre-commit hooks from all sub-repositories to be managed by the main repository. The main repository coordinates the hooks, while each sub-repository implements its own check logic through the `pre-commit-check` target in Makefile.

### Changes

- **Main repository**: Create unified `.githook/pre-commit` hook and `Makefile` that automatically invokes checks for corresponding sub-repositories based on changes
- **backend**: Remove `.githook/pre-commit`, add `pre-commit-check` target in `Makefile` (runs lint and docs generation)
- **frontend**: Remove `.husky` directory, `commitlint.config.cjs` and related dependencies (husky, commitlint, commitizen), add `pre-commit-check` target in `Makefile` (runs lint and lint-staged)
- **storage**: Remove `.githook/pre-commit`, add `pre-commit-check` target in `Makefile` (runs golangci-lint)
- **website**: Remove `scripts/install-git-hooks.mjs` and `scripts/pre-commit`, create `Makefile` and `scripts/check-webp-images.sh`, add `pre-commit-check` target (checks if newly added images are in WebP format)

### Testing

- Test hook scripts for each repository to ensure they work correctly
- Test hook scripts when multiple repositories have changes simultaneously
- Test hook scripts when there are no changes to ensure they output correctly

### Special Notes

As a developer, you need to use `make install-hooks` in the main repository to install the hook scripts. Additionally, please note that if you modify both *backend* and *storage* sub-repositories simultaneously, the scripts may fail to work properly due to Go version inconsistencies.

---

Resolve #208

Resolve #209
```

特别说明：

- 整体的描述不要太长，除非修改非常复杂；如果是简单的修改，那么也请你给出一个简短的 pr 描述，把修改说清楚就行
- 如果无法总结出一定数量的分点，不要硬凑，只有一个或者两个也是可以的
- 你需要动态的判断是否要在每个分点后添加标点
- 不要对用户的测试 case 进行扩充，用户提供了几条测试，就在生成的文本中提供几行对于测试的描述，但是可以进行一定程度上的细化