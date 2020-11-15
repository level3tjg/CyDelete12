#include <spawn.h>

int main(int argc, char **argv, char **envp) {
	setuid(0);
	if (argc <= 1) {
		return 0;
	} else {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *dpkgPath = @"/var/lib/dpkg/info";
		NSArray *dpkgFiles = [fileManager contentsOfDirectoryAtPath:dpkgPath error:nil];
		[dpkgFiles writeToFile:@"/dpkg.plist" atomically:YES];
		NSString *appId =[NSString stringWithFormat:@"%s", argv[1]];
		for (NSString *file in dpkgFiles) {
			if ([file containsString:@".list"]) {
				NSString *fileContent = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", dpkgPath, file] encoding:NSUTF8StringEncoding error:nil];
				if ([fileContent containsString:appId]) {
					bool respring = false;
					if ([fileContent containsString:@"/Library/MobileSubstrate"]) {
						respring = true;
					}
					NSString *pkgIdStr = [file substringToIndex:[file length]-5];
					const char *pkgId = [pkgIdStr cStringUsingEncoding:NSUTF8StringEncoding];
					pid_t pid;
					const char *dpkgArgs[] = {"sudo", "/usr/bin/dpkg", "-r", pkgId, NULL};
					posix_spawn(&pid, "/usr/bin/sudo", NULL, NULL, (char *const *)dpkgArgs, NULL);
					if (respring) {
						const char *respringArgs[] = {"sudo", "/usr/bin/killall", "-9", "SpringBoard", NULL};
						posix_spawn(&pid, "/usr/bin/sudo", NULL, NULL, (char *const *)respringArgs, NULL);
					}
				}
			}
		}
	}
	return 0;
}
