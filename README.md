# WKComplications
_Minimum Reproducible Example_ app to demonstrate the issue with `WidgetKit` complications not updating (watchOS 9/10)

- If the watch app is in the **foreground**, data is transmitted from the companion iPhone app immediately and content is updated in both app and widgets on the watch.
- If the watch app is in the **background** (or hasn't been launched), then there is simply no data transfer happening between devices, which leads to stale data in watch widgets.
- iPhone app has two buttons to submit value to the watch: the top one submits value via the fast, but unreliable channel, and the bottom one uses `complication-related` data transfer API, which in theory should transfer data even if the watch app is in the background.
- `OSLog` for used for logging, so it is possible to observe communication logs in `Console` app.
