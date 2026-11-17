fn main() {
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows") {
        // [PATCH] 图标嵌入失败不再阻断构建：
        // 沙箱 / 缺少 rc.exe 的环境里 winresource 会返回 NotFound，
        // 而图标只是 exe 的装饰，不该让整个 release 编译失败。
        if let Err(err) = winresource::WindowsResource::new()
            .set_icon("assets/icon.ico")
            .compile()
        {
            println!("cargo:warning=嵌入图标失败（已跳过，不影响运行）: {err}");
        }
    }
}
