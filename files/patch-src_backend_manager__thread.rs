--- src/backend/manager_thread.rs.orig	2024-05-05 08:17:37 UTC
+++ src/backend/manager_thread.rs
@@ -596,9 +596,12 @@ async fn command_loop(
                             }
                         },
                         // The network status changed; restart the loop to restart the signal websockets.
-                        _ = crate::utils::await_suspend_wakeup_online().fuse() => {
-                            log::trace!("Waking up from suspend. Restarting command loop.");
-                            break;
+                        r = crate::utils::await_suspend_wakeup_online().fuse() => {
+                            // If the result is not OK, this could mean the dbus service is missing, in which case one should do nothing.
+                            if r.is_ok() {
+                                log::trace!("Waking up from suspend. Restarting command loop.");
+                                break;
+                            }
                         },
                         complete => {
                             log::trace!("Command loop complete. Restarting command loop.");
