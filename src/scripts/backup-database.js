const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const config = require('../src/config/env');

const backupDir = path.join(__dirname, '../backups');

// Create backup directory
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/:/g, '-').split('.')[0];
const backupFile = path.join(backupDir, `backup_${timestamp}.sql`);

const command = `mysqldump -h ${config.database.host} -u ${config.database.user} -p${config.database.password} ${config.database.database} > ${backupFile}`;

exec(command, (error, stdout, stderr) => {
  if (error) {
    console.error('Backup failed:', error);
    process.exit(1);
  }
  
  console.log('✅ Database backup created:', backupFile);
  
  // Compress backup
  exec(`gzip ${backupFile}`, (err) => {
    if (err) {
      console.error('Compression failed:', err);
    } else {
      console.log('✅ Backup compressed');
    }
  });
});