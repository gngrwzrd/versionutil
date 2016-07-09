
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <regex.h>
#include <getopt.h>

const int version_format_none = 0;
const int version_format_short = 1;
const int version_format_long = 2;

char * getForce(char * version) {
	return "";
}

char * getMajor(char * version) {
	return "";
}

char * getMinor(char * version) {
	return "";
}

char * getPatch(char * version) {
	return "";
}

char * getTag(char * version) {
	return "";
}

int validate_version_format(char * version) {
	int res = 0;
	int format = version_format_none;

	regex_t short_regex = NULL;
	res = regcomp(&short_regex,"^(!)?([0-9]*|~?)\\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?$",REG_EXTENDED);

	regex_t long_regex = NULL;
	res = regcomp(&short_regex,"^(!)?([0-9]*|~?)\\.([0-9]*|~?)\\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?$",REG_EXTENDED);
	
	regmatch_t matches[16];
	bzero(matches,sizeof(regmatch_t) * 16);
	res = regexec(&short_regex,version,16,matches,0);
	if(res == 0) {
		format = version_format_short;
	}
	
	bzero(matches,sizeof(regmatch_t) * 16);
	res = regexec(&long_regex,version,16,matches,0);
	if(res == 0) {
		format = version_format_long;
	}

	return format;
}

bool validate_major(char * major) {
	return true;
}

bool validate_minor(char * minor) {
	return true;
}

bool validate_patch(char * patch) {
	return true;
}

bool validate_tag(char * tag) {
	return true;
}

void compare_versions(char * version, char * comparator, char * version2) {

}

int main(int argc, char ** argv) {
	if(argc < 2) {
		printf("Version argument required.\n");
	}
	
	bool increment_patch = false;
	bool increment_minor = false;
	bool increment_major = false;
	bool print_major = false;
	bool print_minor = false;
	bool print_patch = false;
	bool print_tag = false;
	bool has_force = false;
	char * compare = false;
	char * version = NULL;
	char * compare_version = NULL;
	
	if(argc > 2) {
		version = argv[1];
		char * arg = NULL;
		for(int i = 0; i < argc; i++) {
			arg = argv[i];
			if(strcmp(arg,"+patch") == 0) {
				increment_patch = true;
			}
			if(strcmp(arg,"+minor") == 0) {
				increment_minor = true;
			}
			if(strcmp(arg,"+major") == 0) {
				increment_major = true;
			}
			if(strcmp(arg,"--print-major") == 0) {
				print_major = true;
			}
			if(strcmp(arg,"--print-minor") == 0) {
				print_minor = true;
			}
			if(strcmp(arg,"--print-patch") == 0) {
				print_patch = true;
			}
			if(strcmp(arg,"--print-tag") == 0) {
				print_tag = true;
			}
			if(strcmp(arg,"--compare") == 0) {
				compare = arg;
				compare_version = argv[3];
			}
			if(strcmp(arg,"--lt") == 0) {
				compare = arg;
				compare_version = argv[3];
			}
			if(strcmp(arg,"--gt") == 0) {
				compare = arg;
				compare_version = argv[3];
			}
			if(strcmp(arg,"--eq") == 0) {
				compare = arg;
				compare_version = argv[3];
			}
		}
	} else {
		printf("%s",argv[1]);
	}
	
	int format = validate_version_format(version);
	if(format == version_format_none) {
		printf("Invalid version format");
		exit(1);
	}

	char * force = getForce(version);
	char * major = getMajor(version);
	int imajor = 0;
	char * minor = getMinor(version);
	int iminor = 0;
	char * patch = getPatch(version);
	int ipatch = 0;
	char * tag = getTag(version);

	bool zero_major = false;
	if(strcmp(major,"~") == 0) {
		zero_major = true;
		memcpy(major,"0",1);
	}

	bool zero_minor = false;
	if(strcmp(minor,"~") == 0) {
		zero_minor = true;
		memcpy(minor,"0",1);
	}

	bool zero_patch = false;
	if(format == version_format_long) {
		if(strcmp(patch,"~") == 0) {
			zero_patch = true;
			memcpy(patch,"0",1);
		}
	}

	if(!validate_major(major)) {
		printf("Invalid version format");
		exit(1);
	}

	if(!validate_minor(minor)) {
		printf("Invalid version format");
		exit(1);	
	}

	if(format == version_format_long) {
		if(!validate_patch(patch)) {
			printf("Invalid version format");
			exit(1);
		}
	}

	if(!validate_tag(tag)) {

	}

	if(compare != NULL && !validate_version(compare)) {
		if(compare_version != NULL) {
			apply_modifiers(compare_version);
		}
		compare_versions(version,compare,compare_version);
		exit(0);
	}

	if(increment_major && !zero_major && !force) {
		imajor = atoi(major);
		imajor++;
	}

	if(increment_minor && !zero_minor && !force) {
		iminor = atoi(minor);
		iminor++;
	}

	if(format == version_format_long && increment_patch && !zero_patch && !force) {
		ipatch = atoi(patch);
		ipatch++;
	}

	if(print_patch) {
		printf("%s",patch);
		exit(0);
	}

	if(print_minor) {
		printf("%s",minor);
		exit(0);
	}

	if(print_major) {
		printf("%s",major);
		exit(0);
	}

	if(print_tag) {
		printf("%s",tag);
		exit(0);
	}

	if(format == version_format_short) {
		if(tag) {
			printf("%d.%d%s",iminor,imajor,tag);
		} else {
			printf("%d.%d",iminor,imajor);
		}
	}

	if(format == version_format_long) {
		if(tag) {
			printf("%d.%d.%d%s",iminor,imajor,ipatch,tag);
		} else {
			printf("%d.%d.%d",iminor,imajor,ipatch);
		}
	}

	exit(1);
}
