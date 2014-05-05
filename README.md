github上的项目众多，值得收藏的项目不胜枚举，适当的分类和整理有利于弥补watch和star的不足，并能够方便的在多机、朋友间分享。


## 目录命名规则
*   一级目录：参考 framework
*   二级目录：根据**用途**命名，而不是**实现手段**或**实现类**
    *   ui：
    *   foundation：

## git submodule 操作

### 常规操作
```
$ git submodule add https://......
$ git commit
```
```
$ git clone https://github.com/wkevin/iOS.grocery.git
$ cd iOS.grocery
$ git submodule init
$ git submodule update
```
### 存在的问题
1. update 后 submodule 代码不是最新的
  **原因：**
  git submodule的要实现“父项目依赖于子项目”，可以有两种**依赖**方式：
  （1）依赖于某个指定commit，不一定是最新
  （2）依赖于某个子项目的branch
  默认是第（1），所以 `git submodule update` 会按照指定的 commit id 来checkout，而不是 master 的最新。
  **措施：**
  方式（1）的时候，可递归更新所有 submodule  
  ```
  $ git submodule foreach --recursive git fetch origin
  ```
  方式（2）的使用
  ```
  $ git submodule add -b branch-xxx https://......
  ```
  ```
  $ git submodule update --remote
  ```
  这样clone出来的 submodule 将会是 branch-xxx 分支的最新 commit

2. update 后 submodule 的HEAD处于 detached 游离状态
  无论是上面的方式（1）or（2），都会存在此问题
  ```
  $ cd submodule-xxx
  $ git branch -avv
  *(detached from 53d8811) 53d8811 Create README.md
    master                  0163586 [origin/master] Update README.md
    remotes/origin/HEAD     -> origin/master
    remotes/origin/master   0163586 Update README.md
  ```
  **措施：**
  ```
  $ cd submodule-xxx
  $ git checkout branch-xxx
  ```

### 推荐操作
```
$ git submodule add -b master https://......
$ git commit
```
```
$ git clone https://github.com/wkevin/iOS.grocery.git
$ cd iOS.grocery
$ git submodule init
$ git submodule update --remote
$ git submodule foreach --recursive git fetch origin
```

不要试图把最后一句换成
```
$ git submodule foreach --recursive git pull origin master
```
git 的branch很活跃，到底哪个才是你想要的，最好确认好了再merge。



