--- src/dbus/login1.rs	2024-05-05 10:17:37 UTC
+++ src/dbus/login1.rs
@@ -2,9 +2,9 @@ use zbus::{proxy, Connection};
 use zbus::{proxy, Connection};
 
 #[proxy(
-    interface = "org.freedesktop.login1.Manager",
-    default_service = "org.freedesktop.login1",
-    default_path = "/org/freedesktop/login1"
+    interface = "org.freedesktop.ConsoleKit.Manager",
+    default_service = "org.freedesktop.ConsoleKit",
+    default_path = "/org/freedesktop/ConsoleKit/Manager"
 )]
 trait Login1 {
     #[zbus(signal)]
