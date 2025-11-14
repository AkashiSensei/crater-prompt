当涉及项目前端开发时，请 Agent 参考本文档中的信息，你可以将关键的指令与提示总结并输出到对话 context 中，或者提示自己在设计方案和实现时再次查阅文档，方便你在全程记住它们并依照它们行动。

# 项目结构

这章内容主要帮助用户理解和记忆，仅供 Agent 参考。作为 Agent，你可以在你的设计方案和实现中使用下列概念和名词，来帮助用户理解你的设计思想和行为。

## 组件架构分层

项目采用四层组件架构，从底层到顶层依次为：

### 1. 基础组件层 (`src/components/ui/`)
- 基于 shadcn/ui（底层使用 Radix UI）
- 提供无样式或基础样式的基础组件
- 包含：Card、Badge、Button、Form、Input、Dialog 等通用组件
- 职责：提供基础功能和可定制的样式接口

### 2. 自定义样式组件层 (`src/components/ui-custom/`)
- 基于 `ui/` 组件，添加项目特定的自定义样式
- 封装简单的业务逻辑（如单位转换、格式化等）
- 包含：MetricCard、ProgressCard、CardTitle 等
- 职责：统一项目的视觉风格和常用样式模式

### 3. 业务组件层 (`src/components/` 下的其他目录)
- 基于 `ui/` 和 `ui-custom/` 组件构建
- 封装具体的业务逻辑和功能
- 按业务领域组织：`badge/`、`form/`、`job/`、`layout/`、`file/` 等
- 职责：提供可复用的业务功能组件

### 4. 页面层 (`src/routes/`)
- 使用业务组件组合构建完整页面
- 处理页面级的状态管理和路由逻辑
- 职责：组装业务组件，实现具体的页面功能

## 路由系统

项目使用 **TanStack Router**，基于文件系统的路由。

### 路由文件位置
- 路由定义：`src/routes/` 目录下的文件
- 路由树生成：`src/routeTree.gen.ts`（自动生成，不要手动修改）
- 路由配置：`src/router.tsx`

### 路由文件命名规则
- `route.tsx` - 布局路由（使用 `<Outlet />` 渲染子路由）
- `index.tsx` - 索引路由（目录的默认路由）
- `$name.tsx` - 动态路由参数（如 `$name` 表示路径参数）
- `$.tsx` - 捕获所有路由（通配符路由）

### 路由定义方式
每个路由文件使用 `createFileRoute('/path')` 定义，支持：
- `component` - 路由组件
- `loader` - 数据加载器（返回 `crumb` 设置面包屑导航）
- `beforeLoad` - 路由加载前的钩子（常用于权限检查）
- `validateSearch` - 验证 URL 查询参数

### 添加新路由
1. 在 `src/routes/` 下创建文件，文件路径对应 URL 路径
2. 使用 `createFileRoute('/path')` 定义路由
3. 在 `loader` 中返回 `crumb` 设置面包屑导航
4. 路由树会自动生成（开发时自动更新）

### 修改现有路由
- 直接修改对应的路由文件
- 修改路径：重命名文件或目录，路由树会自动更新
- 修改配置：在 `createFileRoute` 中修改相关配置

### 布局路由 vs 动态路由
- **布局路由**：使用 `route.tsx` 命名，通过 `<Outlet />` 为子路由提供共享布局（如侧边栏、导航栏）
- **动态路由**：使用 `$name.tsx` 命名，匹配 URL 参数，通过 `Route.useParams()` 获取参数值

## 页面布局组件

项目提供了几种主要的页面布局组件，用于构建不同类型的页面：

### DataTable 组件 (`src/components/query-table/index.tsx`)

用于数据表格展示的通用组件，内置了完整的表格功能。

**核心特性**：
- 基于 `@tanstack/react-table` 和 `@tanstack/react-query`
- 状态持久化（筛选条件、分页大小保存到 localStorage）
- 支持批量操作（通过 `multipleHandlers` prop）

**标题显示方式**：
- 通过 `info` prop 传递标题信息，组件内部使用 `PageTitle` 渲染
- 如果传递了 `info`，操作按钮（`children`）显示在标题右侧
- 如果没有 `info`，操作按钮显示在工具栏中

### DetailPage 组件 (`src/components/layout/detail-page.tsx`)

用于详情页的完整布局组件，包含标题、信息卡片和标签页。

**核心 Props**：
- `header: ReactNode` - 页面头部（通常使用 `DetailTitle` 或 `PageTitle`）
- `info: DetailInfoProps[]` - 三列详细信息数组（每项包含 `icon`、`title`、`value`）
- `tabs: DetailTabProps[]` - 标签页配置数组
- `currentTab?: string` - 当前选中的标签页
- `setCurrentTab?: (tab: string) => void` - 切换标签页的回调

**三列信息展示**：
- 使用 Tailwind CSS 的 `grid grid-cols-3` 实现固定三列布局
- 不依赖其他业务组件，是组件内置功能
- 每列显示：图标 + 标题 + 值

### DetailTitle 组件 (`src/components/layout/detail-title.tsx`)

用于详情页的标题组件，支持大图标和描述。

**特点**：
- 大标题样式（`text-3xl`）
- 支持图标显示（20x20 图标容器）
- 支持在标题右侧放置操作按钮（通过 `children` prop）

**与 DetailPage 的关系**：
- `DetailTitle` 不是 `DetailPage` 的一部分，而是通过 `header` prop 组合进来
- `DetailPage` 不依赖 `DetailTitle`，可以传入任何 React 组件作为 `header`
- 这是组合模式（Composition Pattern）的体现

### PageTitle 组件 (`src/components/layout/page-title.tsx`)

用于普通页面的简洁标题组件。

**特点**：
- 简洁样式（`text-xl`）
- 不支持图标
- 支持描述文本和操作按钮

**使用场景**：
- 独立页面（不使用 `DetailPage` 时）
- 通过 `DataTable` 的 `info` prop 传递时，内部也会使用 `PageTitle`

### 页面布局选择建议

| 场景 | 推荐组件 | 说明 |
|------|---------|------|
| 列表页面（带标题和操作按钮） | `DataTable` + `info` prop | 标题和表格集成在一起 |
| 详情页面（多标签页、三列信息） | `DetailPage` + `DetailTitle` | 完整的详情页布局 |
| 简单页面（单一内容） | `PageTitle` + 内容组件 | 最简洁的方式 |
| 详情页面（但不需要标签页） | `DetailTitle` + 自定义布局 | 不使用 `DetailPage`，自行组合 |

**重要原则**：
- `DetailPage` 和 `DetailTitle` 是组合关系，不是包含关系
- `DetailPage` 的 `header` prop 可以传入任何 React 组件（`DetailTitle`、`PageTitle` 或自定义组件）
- 三列信息展示是 `DetailPage` 的内置功能，通过 Tailwind CSS grid 实现，不依赖其他业务组件

### 组件嵌套和调用链

在详情页面中，`DataTable` 的使用有两种常见模式：

**模式1：通过业务组件包装（推荐）**
```
页面组件 ($id.tsx)
  └─ DetailPage
      └─ tabs[].children
          └─ 业务组件 (如 AccountMemberTable、PodTable)
              └─ DataTable
```

**模式2：直接在标签页中使用**
```
页面组件或业务组件
  └─ DetailPage
      └─ tabs[].children
          └─ DataTable (直接使用)
```

**实际项目中的使用情况**：
- **模式1示例**：
  - `AccountMemberTable` 组件（`src/components/account/account-member-table.tsx`）- 在账户详情页的用户标签页中使用
  - `PodTable` 组件（`src/components/job/detail/pod-table.tsx`）- 在作业详情页的基本信息标签页中使用
  - 优点：业务逻辑封装在组件内，可复用性强，职责分离清晰
  
- **模式2示例**：
  - `SharedResourceTable` 组件（`src/components/file/data-detail.tsx`）- 在数据详情页的多个标签页中直接使用 `DataTable`
  - 优点：代码更简洁，适合简单的表格展示场景

**选择建议**：
- 如果表格有复杂的业务逻辑（如添加、编辑、删除等操作），使用**模式1**，创建业务组件封装逻辑
- 如果只是简单的数据展示，可以直接在标签页的 `children` 中使用 `DataTable`（**模式2**）
- 无论使用哪种模式，都不要在页面组件中直接使用 `DataTable`，而应该通过 `DetailPage` 的标签页机制来组织内容


# 注意事项（提示词）

这章对于 Agent 非常关键，请在整个开发流程中牢记以下提示，如有需要，请你以便于你在整个会话中保持长期记忆的方式输出它们，或者提示自己在需要时再次查阅文档。

## 整体

在你给出设计或实现方案时：

- 必须尽量复用上述层次中已经有的组件，如果没有相关的组件，再考虑新建
- 由于组件的复用程度高，修改它们必须非常谨慎，如果你决定要修改某个组件，你需要给用户输出充分的原因，并检查所有对于该组件的引用
- 尽量保持风格和颜色的一致，尤其是新的页面，请参考现有页面的布局方式
- 考虑人文关怀，包括按钮的顺序等细节可能需要额外的思考
- 前端配置了多语言，在实现和修改过程中，请你注意不要硬编码文本，并且我们先只提供中文文本，完成后再统一翻译到其他语言的 json 中

## 具体
- 当用户需要判断当前用户正在使用的身份时，请使用 `frontend/src/hooks/use-admin.tsx` 中提供的 `useIsAdmin()`
- `frontend/src/hooks` 目录下还提供了其它的 hooks，如果你在实现相关功能，请先检查这里是否有能够直接使用的内容
- 对于新建的页面，请不要忘记设置它的面包屑导航