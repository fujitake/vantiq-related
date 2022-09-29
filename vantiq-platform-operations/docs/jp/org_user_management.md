# Vantiq Organization, Namespace, User Role の関係

### Namespace とは
- Namespace は開発リソースを排他的に分離することを保証します。
- 開発 Resource とは、App、Procedure、Rule、Client、Project そしてUser等を含みます。
- ユーザーは、招待されたNamespaceへアクセスすることができます。

![namespaces](../../imgs/org-user-management/namespaces.png)

- Namespaceには４種類あり、用途が異なります。
  - **System NS** – Vantiqクラスタ全体に関するリソースを管理する
  - **Organization Root NS** – Organization（テナント）を管理する
  - **Developer NS** – 開発者がアプリケーションを開発（開発リソースを作成）する
  - **Application NS** – 運用者がアプリケーションのユーザーを管理し、アプリケーションをデプロイ、運用する
- Note: ユーザーにはNamespaceの種類は表示されません。

<img src="../../imgs/org-user-management/namespace-hierarchy.png" width="50%"/>

### Roleの種類とNamespaceとの関係
- それぞれのNamespaceの種類について取りうるRoleが定義されており、ユーザーはRoleをアサインされることで、操作を行うことができます。


NSの種類 | Role | 主な責任 | 新規ユーザー作成 | 新規NS作成 | 開発リソース作成
--|---|---|---|---|--
System NS | System Admin |- システム全体の管理<br /> - Organizationの作成、管理  | **Yes (1)** | **Yes (2)**  | **Yes (3)** |  
Organization Root NS | Organization Admin  | - Organization全体の管理  | **Yes** | **Yes**  | **Yes (3)**
 Organization Root NS | User(Developer)  | - Developer NSの管理  | No  | **Yes**  | No  
Developer NS  | Developer  | - 開発・保守作業  | No  | **Yes**  | **Yes**
Application NS  | NS Admin  | - アプリケーションの運用 <br /> - エンドユーザー管理  | **Yes** | No | No
Application NS  | User  | - アプリケーションの利用 | No | No | No

- (1) System Adminを新規に招待できる。また、Organization作成時にOrganization Adminを新規に招待できる。
- (2) Organization Root NSのみ作成できる。
- (3) 作成はできるが推奨しない。

### Namespace へ招待する
- 権限を持ったユーザーは、招待メールを送ることでNSへのアクセスを与えることができます。

#### 新規Userを招待する
- 管理 >> ユーザー >> New)

<img src="../../imgs/org-user-management/invite-new-users.png" width="50%"/>

#### 既存UserにNSへ権限を付与する
- 管理 >> Namespace >> Manage Authorization

<img src="../../imgs/org-user-management/invite-existing-user.png" width="50%"/>


### ユーザー利用開始シナリオ

#### 1) System AdminはOrganizationを作成する
- System AdminはOrganizationを作成し、同時にOrganization Adminを招待、割り当てます。

![step1](../../imgs/org-user-management/step1.png)

#### 2) Organization AdminはDeveloperを招待する

- Organization AdminはDeveloperを User (Developer)というロールで招待します。

![step2](../../imgs/org-user-management/step2.png)

#### 3) Developerは開発用のNamespaceを作成する

- Developerは開発用のNamespaceを作成し、Developerとなります。

![step3](../../imgs/org-user-management/step3.png)

#### 4) Developerは開発用のNamespaceに他の開発者を招待する

- Developerに既存ユーザーをDeveloperとして招待します。

![step4](../../imgs/org-user-management/step4.png)

#### 5) Organization AdminはNS Adminを招待する

- Organization AdminはApplication NSを作成します。そのNSにユーザーをNS Adminとして招待します

![step5](../../imgs/org-user-management/step5.png)

#### 6) NS AdminはUserを招待する

- NS AdminはユーザーをUserとして招待します。

![step6](../../imgs/org-user-management/step6.png)


### Home Namespace と Current Namespace

- **Home Namespace** - ユーザーのアカウント作成時（初めてNSに招待された時）のNamespaceで、ユーザー情報はHome Namespaceで管理されます。変更をすることができません。

<img src="../../imgs/org-user-management/home-namespace.png" width="50%"/>


- **Current Namespace** – 現在作業中のNamespaceです。

<img src="../../imgs/org-user-management/current-namespace.png" width="50%"/>

## References
- [Administrators Reference Guide](https://internal.vantiqjp.com/docs/system/namespaces/index.html)
