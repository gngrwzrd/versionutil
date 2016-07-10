
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <strings.h>
#include <string.h>
#include <regex.h>
#include <getopt.h>

const int version_format_none = 0;
const int version_format_short = 1;
const int version_format_long = 2;

bool perform_regex(char * pattern, char * search, int extract_index_match, char ** match_content) {
	regex_t reg;
	regmatch_t matches[16];
	bzero(matches,sizeof(regmatch_t)*16);
	int res = regcomp(&reg,pattern,REG_EXTENDED);
	if(res != 0) {
		return false;
	}
	res = regexec(&reg,search,16,matches,0);
	if(res != 0) {
		return false;
	}
	if(extract_index_match > reg.re_nsub) {
		return false;
	}
	char * buf = calloc(1,32);
	regmatch_t match = matches[extract_index_match];
	memcpy(buf,&(search[match.rm_so]),match.rm_eo-match.rm_so);
	if(match_content) {
		*match_content = buf;
	}
	if(strlen(buf) == 0) {
		free(buf);
		if(match_content) {
			*match_content = NULL;
		}
	}
	return true;
}

bool get_force(char * version) {
	if(!version) {
		return NULL;
	}
	char * pattern ="^(!)?";
	char * force = NULL;
	if(!perform_regex(pattern,version,1,&force)) {
		return false;
	}
	if(strcmp(force,"!") != 0) {
		return false;
	}
	return true;
}

char * get_major(char * version) {
	if(!version) {
		return NULL;
	}
	char * pattern ="^(!)?([0-9]*|~?)";
	char * major = NULL;
	if(!perform_regex(pattern,version,2,&major)) {
		return NULL;
	}
	return major;
}

char * get_minor(char * version) {
	if(!version) {
		return NULL;
	}
	char * pattern ="^(!)?([0-9]*|~?)\\.([0-9]*|~?)";
	char * minor = NULL;
	if(!perform_regex(pattern,version,3,&minor)) {
		return NULL;
	}
	return minor;
}

char * get_patch(char * version) {
	if(!version) {
		return NULL;
	}
	char * pattern ="^(!)?([0-9]*|~?)\\.([0-9]*|~?)\\.([0-9]*|~?)";
	char * patch = NULL;
	if(!perform_regex(pattern,version,4,&patch)) {
		return NULL;
	}
	return patch;
}

char * get_tag(char * version, int format) {
	if(!version) {
		return NULL;
	}
	char * pattern = NULL;
	char * tag = NULL;
	if(format == version_format_long) {
		pattern ="^(!)?([0-9]*|~?)\\.([0-9]*|~?)\\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?";
		if(!perform_regex(pattern, version, 5, &tag)) {
			return NULL;
		}
	}
	if(format == version_format_short) {
		pattern = "^(!)?([0-9]*|~?)\\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?";
		if(!perform_regex(pattern, version, 4, &tag)) {
			return NULL;
		}
	}
	return tag;
}

int validate_version_get_format(char * version) {
	int res = 0;
	int format = version_format_none;
	
	regex_t short_regex;
	res = regcomp(&short_regex,"^(!)?([0-9]*|~?)\\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?$",REG_EXTENDED);
	
	regex_t long_regex;
	res = regcomp(&long_regex,"^(!)?([0-9]*|~?)\\.([0-9]*|~?)\\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?$",REG_EXTENDED);
	
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
	return perform_regex("^([0-9]*)|~?$",major,1,NULL);
}

bool validate_minor(char * minor) {
	return perform_regex("^([0-9]*)|~?$",minor,1,NULL);
}

bool validate_patch(char * patch) {
	return perform_regex("^([0-9]*)|~?$",patch,1,NULL);
}

bool validate_tag(char * tag) {
	return perform_regex("^([-|+][a-zA-Z0-9]*)$",tag,1,NULL);
}

void compare_versions(char * version, char * comparator, char * version2) {
	
}

int main(int argc, char ** argv) {
	if(argc < 2) {
		printf("Version argument required.\n");
		exit(1);
	}
	
	bool increment_patch = false;
	bool increment_minor = false;
	bool increment_major = false;
	bool print_major = false;
	bool print_minor = false;
	bool print_patch = false;
	bool print_tag = false;
	char * compare = false;
	char * version = NULL;
	char * compare_version = NULL;
	
	if(argc >= 2) {
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
	
	int format = validate_version_get_format(version);
	if(format == version_format_none) {
		printf("Invalid version format");
		exit(1);
	}
	
	bool force = get_force(version);
	char * major = get_major(version);
	char * minor = get_minor(version);
	char * patch = NULL;
	if(format == version_format_long) {
		patch = get_patch(version);
	}
	char * tag = get_tag(version,format);
	
	int imajor = 0;
	int iminor = 0;
	int ipatch = 0;
	
	bool zero_major = false;
	if(strcmp(major,"~") == 0) {
		zero_major = true;
		memcpy(major,"0",1);
	} else {
		imajor = atoi(major);
	}
	
	bool zero_minor = false;
	if(strcmp(minor,"~") == 0) {
		zero_minor = true;
		memcpy(minor,"0",1);
	} else {
		iminor = atoi(minor);
	}
	
	bool zero_patch = false;
	if(format == version_format_long) {
		if(strcmp(patch,"~") == 0) {
			zero_patch = true;
			memcpy(patch,"0",1);
		} else {
			ipatch = atoi(patch);
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
	
	if(tag && !validate_tag(tag)) {
		printf("Invalid version format");
		exit(1);
	}
	
	if(compare != NULL) {
		if(compare_version != NULL) {
			
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
			printf("%d.%d%s",imajor,iminor,tag);
		} else {
			printf("%d.%d",imajor,iminor);
		}
	}
	
	if(format == version_format_long) {
		if(tag) {
			printf("%d.%d.%d%s",imajor,iminor,ipatch,tag);
		} else {
			printf("%d.%d.%d",imajor,iminor,ipatch);
		}
	}
	
	exit(0);
}
