import { homedir, platform } from 'os';
import { join } from 'path';
import { readFileSync } from 'fs';

export const NotificationPlugin = async ({ $, client }) => {
    const iconPath = join(
        homedir(),
        '.config/opencode/images/opencode-logo-light.png'
    );

    // Detect if running in WSL
    const isWSL = () => {
        if (platform() !== 'linux') return false;
        try {
            const procVersion = readFileSync('/proc/version', 'utf8').toLowerCase();
            return procVersion.includes('microsoft') || procVersion.includes('wsl');
        } catch {
            return false;
        }
    };

    // Check if wsl-notify-send.exe is available
    const hasWslNotifySend = async () => {
        try {
            await $`which wsl-notify-send.exe`;
            return true;
        } catch {
            return false;
        }
    };

    // Send notification based on platform
    const sendNotification = async (title, message) => {
        if (isWSL()) {
            // Try wsl-notify-send first (recommended for WSL)
            if (await hasWslNotifySend()) {
                await $`wsl-notify-send.exe --category "OpenCode" --app-id "OpenCode" "${title}" "${message}"`;
            } else {
                // Fallback to notify-send if available
                await $`notify-send ${title} ${message} -i ${iconPath}`;
            }
        } else if (platform() === 'win32') {
            // Use PowerShell BurntToast on Windows
            await $`pwsh -NoProfile -Command "New-BurntToastNotification -Text '${title}','${message}' -AppLogo '${iconPath}'"`;
        } else {
            // Use notify-send on other Linux/Unix systems
            await $`notify-send ${title} ${message} -i ${iconPath}`;
        }
    };

    // Check if a session is a main (non-subagent) session
    const isMainSession = async (sessionID) => {
        try {
            const result = await client.session.get({
                path: { id: sessionID }
            });
            const session = result.data ?? result;
            return !session.parentID;
        } catch {
            // If we can't fetch the session, assume it's main to avoid missing notifications
            return true;
        }
    };

    return {
        event: async ({ event }) => {
            // Only notify for main session events, not background subagents
            if (event.type === 'session.idle') {
                const sessionID = event.properties.sessionID;
                if (await isMainSession(sessionID)) {
                    await sendNotification('OpenCode', 'Agent Complete');
                }
            }

            // Permission prompt created
            if (event.type === 'permission.asked') {
                await sendNotification('OpenCode', 'Agent Complete');
            }
        }
    };
};
