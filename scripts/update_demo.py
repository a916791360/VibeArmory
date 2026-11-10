import shutil

shutil.copyfile('Sources/VibeArmory/Resources/AppLogo.png', 'design-demos/AppLogo.png')

with open('design-demos/index.html', 'r', encoding='utf-8') as f:
    text = f.read()

# Remove icon box
text = text.replace('<div class="card-icon-box">${p.icon}</div>', '')

# Replace header logo
old_header_logo = """            <div class="hud-logo">
              ${dirKey === 'c' ? '<div class="led-indicator"></div>' : ''}
              <span class="hud-logo-icon">⚡️</span>
              <span>VIBEARMORY</span>
            </div>"""

new_header_logo = """            <div class="hud-logo" style="display:flex; align-items:center; gap:8px;">
              <img src="AppLogo.png" style="width:26px; height:26px; border-radius:6.5px; box-shadow:0 2px 8px rgba(0,0,0,0.4); border:1px solid rgba(255,255,255,0.25); object-fit:cover;">
              <span style="font-weight:700; letter-spacing:-0.2px">VibeArmory</span>
            </div>"""

text = text.replace(old_header_logo, new_header_logo)

with open('design-demos/index.html', 'w', encoding='utf-8') as f:
    f.write(text)

print("design-demos/index.html successfully updated!")
