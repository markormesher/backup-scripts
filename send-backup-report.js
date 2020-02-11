const { exec } = require("child_process");
const https = require('https');

(async () => {
  const reportItems = [
    {
      label: "Chuck Backup",
      thresholdHours: 25,
      lastRun: new Date((await execCommand("borg list --prefix chuck --format '{end}{NEWLINE}' --sort-by timestamp /hdd/borg/repo0 | tail -n 1")).trim()),
    },
    {
      label: "Casey Backup",
      thresholdHours: 7 * 24,
      lastRun: new Date((await execCommand("borg list --prefix casey --format '{end}{NEWLINE}' --sort-by timestamp /hdd/borg/repo0 | tail -n 1")).trim()),
    },
    {
      label: "Archive Backup",
      thresholdHours: 7 * 24,
      lastRun: new Date((await execCommand("borg list --prefix archive --format '{end}{NEWLINE}' --sort-by timestamp /hdd/borg/repo0 | tail -n 1")).trim()),
    },
    {
      label: "Backup Prune",
      thresholdHours: 25,
      lastRun: new Date((await execCommand("cat data/last-prune-morgan-backups.txt")).trim()),
    },
    {
      label: "Backup Sync to B2",
      thresholdHours: 25,
      lastRun: new Date((await execCommand("cat data/last-sync-morgan-to-b2.txt")).trim()),
    },
  ];

  const storageItems = [
    {
      label: "/hdd/borg/repo0",
      size: (await execCommand("du -h --max-depth 0 /hdd/borg/repo0 | awk '{ print $1 }'")).trim(),
    },
  ];

  const overallStatus = getOverallStatus(reportItems);

  let reportBody = `
  <html>
    <body>
      <h3>Scheduled Task Report</h3>
      <table>
        ${reportItems.map(getReportRow).join("")}
      </table>
      <h3>Storage Report</h3>
      <table>
        ${storageItems.map(getStorageRow).join("")}
      </table>
    </body>
  </html>
  `;

  const data = JSON.stringify({
    personalizations: [
      {
        to: [
          {
            email: "me@markormesher.co.uk"
          },
        ],
      },
    ],
    from: {
      email: "me@markormesher.co.uk"
    },
    subject: `[${overallStatus}] Backup Report - ${new Date().toString()}`,
    content: [
      {
        type: "text/html",
        value: reportBody,
      },
    ],
  });

  const options = {
    hostname: "api.sendgrid.com",
    port: 443,
    path: "/v3/mail/send",
    method: "POST",
    headers: {
      "Authorization": `Bearer ${process.env.SENDGRID_API_KEY}`,
      "Content-Type": "application/json",
      "Content-Length": data.length,
    },
  };

  const req = https.request(options);
  req.on("error", (e) => console.log(e));
  req.write(data)
  req.end()
})();

function getOverallStatus(reportItems) {
  const now = new Date();
  const anyOverThreshold = reportItems
    .map((reportItem) => {
      const hoursDiff = (now.getTime() - reportItem.lastRun.getTime()) / 1000 / 60 / 60;
      return hoursDiff > reportItem.thresholdHours;
    })
    .some((overThreshold) => overThreshold);
  return anyOverThreshold ? "ERROR" : "OKAY";
}

function getReportRow(reportItem) {
  const now = new Date();
  const hoursDiff = (now.getTime() - reportItem.lastRun.getTime()) / 1000 / 60 / 60;
  const colour = isNaN(hoursDiff) || hoursDiff > reportItem.thresholdHours ? "#990000" : "#009900";
  return `
  <tr>
    <td><strong>${reportItem.label}</strong></td>
    <td style="width: 20px"></td>
    <td style="color: ${colour}">${Math.round(hoursDiff * 10) / 10}h ago</td>
    <td style="width: 20px"></td>
    <td style="color: ${colour}">${reportItem.lastRun.toString()}</td>
  </tr>
  `;
}

function getStorageRow(storageItem) {
  return `
  <tr>
    <td><strong>${storageItem.label}</strong></td>
    <td style="width: 20px"></td>
    <td>${storageItem.size}</td>
  </tr>
  `;
}

async function execCommand(command) {
  return new Promise(function(resolve, reject) {
    exec(command, function(error, standardOutput, standardError) {
      if (error) {
        reject(error);
        return;
      }

      if (standardError) {
        reject(standardError);
        return;
      }

      resolve(standardOutput);
    });
  });
}
