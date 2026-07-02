# Permissions

## Roles

This simulator version has no server-side user accounts, roles, or claims. All interactions run as a local simulator user.

## Resource Matrix

| Resource | Operation | Allowed Actor | Enforcement |
| --- | --- | --- | --- |
| WebView UI state | Read/write | Local simulator user | Browser localStorage |
| Onboarding profile | Read/write | Local simulator user | Browser localStorage |
| PillowTalk entries | Read/write | Local simulator user | Browser localStorage |
| Bundled assets | Read | Native app/WebView | Expo asset manifest |
| Voice preview audio | Read/play | Native app/WebView | Bundled local files |

## Deny Cases

- No network authorization path exists in the simulator.
- No backend database exists in this package.
- No protected admin surface exists.

## Reviewer Notes

Security review should focus on not bundling secrets into the client and on keeping any future API integration behind explicit authorization. Current PillowTalk chat is local mock logic and does not transmit user text.
