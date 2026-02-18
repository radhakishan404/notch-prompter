const REPO_OWNER = "radhakishan404";
const REPO_NAME = "notch-prompter";
const FALLBACK_RELEASES = `https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest`;

async function loadLatestRelease() {
  const btn = document.getElementById("download-btn");
  const meta = document.getElementById("release-meta");

  try {
    const response = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest`, {
      headers: {
        Accept: "application/vnd.github+json"
      }
    });

    if (!response.ok) {
      throw new Error(`GitHub API error: ${response.status}`);
    }

    const release = await response.json();
    const dmgAsset = (release.assets || []).find((asset) =>
      asset.name.toLowerCase().endsWith(".dmg")
    );

    if (dmgAsset) {
      btn.href = dmgAsset.browser_download_url;
      btn.textContent = `Download ${release.tag_name}`;
      meta.textContent = `${release.tag_name} · ${dmgAsset.name} · ${formatSize(dmgAsset.size)}`;
    } else {
      btn.href = FALLBACK_RELEASES;
      btn.textContent = "View Releases";
      meta.textContent = `${release.tag_name} is live. DMG asset not detected yet.`;
    }
  } catch (error) {
    btn.href = FALLBACK_RELEASES;
    btn.textContent = "View Releases";
    meta.textContent = "Unable to load latest release metadata. Open GitHub releases instead.";
    console.error(error);
  }
}

function formatSize(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

loadLatestRelease();
