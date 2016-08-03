
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <strings.h>
#include <string.h>
#include <regex.h>

//version formats
const int version_format_none = 0;
const int version_format_short = 1;
const int version_format_long = 2;

//version_t
typedef struct {
	//this must be set before calling version_parse
	char * version_input;

	//this is updated, call version_updated_output.
	char * version_output;

	//version format.
	int format;

	//wether or not the force ! modifier was present.
	bool forced;

	//major component value
	int major;

	//whether major was set to 0 because of ~ modifier.
	bool major_was_zeroed;

	//minor component value
	int minor;

	//whether minor was set to 0 because of ~ modifier.
	bool minor_was_zeroed;

	//patch component value
	int patch;

	//whether patch was set to 0 because of ~ modifier.
	bool patch_was_zeroed;

	//tag component value
	char * tag;

} version_t;

//version methods
void version_init(version_t * version, char * input_verion);
void version_parse(version_t * version, char ** error);
void version_free(version_t * version);
void version_increment(version_t * version, bool incmajor, bool incminor, bool incpatch, char ** error);
bool version_lt(version_t * version1, version_t * version2);
bool version_gt(version_t * version1, version_t * version2);
bool version_eq(version_t * version1, version_t * version2);
int version_compare(version_t * version1, char * comparator, version_t * version2);
void version_update_output(version_t * version);

//utility methods used internally to version methods above.
static bool perform_regex(char * pattern, char * search, int extract_index_match, char ** match_content);
static bool get_force(char * version);
static char * get_major(char * version);
static char * get_minor(char * version);
static char * get_patch(char * version);
static char * get_tag(char * version, int format);
static int validate_format(char * version);
static bool validate_minor(char * minor);
static bool validate_patch(char * patch);
static bool validate_tag(char * tag);

void version_init(version_t * version, char * input_version) {
	version->version_input = input_version;
}

void version_free(version_t * version) {
	if(version->tag) {
		free(version->tag);
	}
	if(version->version_output) {
		free(version->version_output);
	}
}

void parse_version(version_t * version, char ** error) {
	if(!version->version_input) {
		*error = "Invalid version format";
		return;
	}

	int format = validate_format(version->version_input);
	if(format == version_format_none) {
		*error = "Invalid version format";
		return;
	}
	version->format = format;

	char * tag = get_tag(version->version_input,version->format);
	if(tag && !validate_tag(tag)) {
		*error = "Invalid version format";
		return;
	}

	bool forced = get_force(version->version_input);
	char * major = get_major(version->version_input);
	char * minor = get_minor(version->version_input);
	char * patch = NULL;
	if(format == version_format_long) {
		patch = get_patch(version->version_input);
	}

	if(!major) {
		*error = "Invalid version format";
		return;
	}

	if(!minor) {
		*error = "Invalid version format";
		return;
	}

	if(version->format == version_format_long && !patch) {
		*error = "Invalid version format";
		return;
	}

	int imajor = 0;
	int iminor = 0;
	int ipatch = 0;

	if(strcmp(major,"~") == 0) {
		imajor = 0;
		version->major_was_zeroed = true;
	} else {
		imajor = atoi(major);
	}

	if(strcmp(minor,"~") == 0) {
		iminor = 0;
		version->minor_was_zeroed = true;
	} else {
		iminor = atoi(minor);
	}

	if(patch && version->format == version_format_long) {
		if(strcmp(patch,"~") == 0) {
			ipatch = 0;
			version->patch_was_zeroed = true;
		} else {
			ipatch = atoi(patch);
		}
	}

	if(!validate_minor(minor)) {
		*error = "Invalid version format";
		return;
	}

	if(version->format == version_format_long && patch && !validate_patch(patch)) {
		*error = "Invalid version format";
		return;
	}

	version->major = -1;
	version->minor = -1;
	version->patch = -1;
	version->tag = NULL;

	version->forced = forced;
	version->major = imajor;
	version->minor = iminor;

	if(version->format == version_format_long) {
		version->patch = ipatch;
	}

	if(tag) {
		version->tag = tag;
	}

	version_update_output(version);
}

void version_update_output(version_t * version) {
	char * version_out = calloc(1,64);
	if(version->format == version_format_long) {
		if(version->tag) {
			sprintf(version_out,"%d.%d.%d%s",version->major,version->minor,version->patch,version->tag);
		} else {
			sprintf(version_out,"%d.%d.%d",version->major,version->minor,version->patch);
		}
	}
	else if(version->format == version_format_short) {
		if(version->tag) {
			sprintf(version_out,"%d.%d%s",version->major,version->minor,version->tag);
		} else {
			sprintf(version_out,"%d.%d",version->major,version->minor);
		}
	}
	version->version_output = version_out;
}

void version_increment(version_t * version, bool incmajor, bool incminor, bool incpatch, char ** error) {
	if(version->forced) {
		*error = NULL;
		return;
	}

	if(incmajor && !version->forced && !version->major_was_zeroed) {
		version->major++;
	}

	if(incminor && !version->forced && !version->minor_was_zeroed) {
		version->minor++;
	}

	if(version->format == version_format_long && incpatch && !version->forced &&!version->patch_was_zeroed) {
		version->patch++;
	}

	version_update_output(version);

	*error = NULL;
}

bool version_lt(version_t * version1, version_t * version2) {
	if(version2->major < version1->major) {
		return false;
	}
	if(version2->minor < version1->minor) {
		return false;
	}
	if(version2->format == version_format_long && version1->format == version2->format) {
		if(version2->patch < version1->patch) {
			return false;
		}
	}
	if(version_eq(version1, version2)) {
		return false;
	}
	return true;
}

bool version_gt(version_t * version1, version_t * version2) {
	if(version2->major > version1->major) {
		return false;
	}
	if(version2->minor > version1->minor) {
		return false;
	}
	if(version2->format == version_format_long && version1->format == version2->format) {
		if(version2->patch > version1->patch) {
			return false;
		}
	}
	if(version_eq(version1, version2)) {
		return false;
	}
	return true;
}

bool version_eq(version_t * version1, version_t * version2) {
	if(version1->major == version2->major) {
		if(version1->minor == version2->minor) {
			if(version1->format == version_format_long && version1->format == version2->format) {
				if(version1->patch == version2->patch) {
					return true;
				}
			} else {
				return true;
			}
		}
	}
	return false;
}

int version_compare(version_t * version1, char * comparator, version_t * version2) {
	if(version_eq(version1,version2)) {
		return 0;
	}
	if(version_lt(version1, version2)) {
		return -1;
	}
	return 1;
}

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
	if(!force) {
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

int validate_format(char * version) {
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

bool validate_minor(char * minor) {
	if(!minor) {
		return false;
	}
	return perform_regex("^([0-9]*)|~?$",minor,1,NULL);
}

bool validate_patch(char * patch) {
	if(!patch) {
		return false;
	}
	return perform_regex("^([0-9]*)|~?$",patch,1,NULL);
}

bool validate_tag(char * tag) {
	return perform_regex("^([-|+][a-zA-Z0-9]*)$",tag,1,NULL);
}

int main(int argc, char ** argv) {
	if(argc < 2) {
		printf("Version argument required.\n");
		exit(1);
	}

	int exit_status = 0;
	char * error = NULL;

	version_t version;
	bzero(&version,sizeof(version));

	bool inc_major = false;
	bool inc_minor = false;
	bool inc_patch = false;

	bool print_major = false;
	bool print_minor = false;
	bool print_patch = false;
	bool print_tag = false;

	char * compare = false;
	version_t compare_version;
	bzero(&compare_version, sizeof(compare_version));

	if(argc >= 2) {
		version_init(&version,argv[1]);
		char * arg = NULL;
		for(int i = 0; i < argc; i++) {
			arg = argv[i];
			if(strcmp(arg,"+patch") == 0) {
				inc_patch = true;
			}
			if(strcmp(arg,"+minor") == 0) {
				inc_minor = true;
			}
			if(strcmp(arg,"+major") == 0) {
				inc_major = true;
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
			}
			if(strcmp(arg,"--lt") == 0) {
				compare = arg;
			}
			if(strcmp(arg,"--gt") == 0) {
				compare = arg;
			}
			if(strcmp(arg,"--eq") == 0) {
				compare = arg;
			}
		}
	} else {
		printf("%s",argv[1]);
	}

	parse_version(&version,&error);
	if(error) {
		printf("%s\n",error);
		exit_status = 1;
		goto cleanup;
	}

	version_increment(&version,inc_major,inc_minor,inc_patch,&error);
	if(error) {
		printf("%s\n",error);
		exit_status = 1;
		goto cleanup;
	}

	if(compare != NULL) {
		version_init(&compare_version,argv[3]);

		parse_version(&compare_version,&error);
		if(error) {
			printf("%s\n",error);
			exit_status = 1;
			goto cleanup;
		}

		if(version.format != compare_version.format) {
			printf("Invalid version format\n");
			exit_status = 1;
			goto cleanup;
		}

		version_increment(&compare_version,inc_major,inc_minor,inc_patch,&error);
		if(error) {
			printf("%s\n",error);
			exit_status = 1;
			goto cleanup;
		}

		if(strcmp(compare,"--lt") == 0) {
			printf("%s\n",version_lt(&version,&compare_version)?"true":"false");
			goto cleanup;
		}

		if(strcmp(compare,"--gt") == 0) {
			printf("%s\n",version_gt(&version,&compare_version)?"true":"false");
			goto cleanup;
		}

		if(strcmp(compare,"--eq") == 0) {
			printf("%s\n",version_eq(&version,&compare_version)?"true":"false");
			goto cleanup;
		}

		int res = version_compare(&version, compare, &compare_version);
		if(res == -1) {
			printf("lt\n");
		} else if(res == 0) {
			printf("eq\n");
		} else if (res == 1) {
			printf("gt\n");
		}

		goto cleanup;
	}

	if(print_major) {
		printf("%d\n",version.major);
		goto cleanup;
	}

	if(print_minor) {
		printf("%d\n",version.minor);
		goto cleanup;
	}

	if(version.format == version_format_long && print_patch) {
		printf("%d\n",version.patch);
		goto cleanup;
	}

	if(print_tag && version.tag) {
		printf("%s\n",version.tag);
		goto cleanup;
	}

	printf("%s\n",version.version_output);

cleanup:

	version_free(&version);
	version_free(&compare_version);

	exit(exit_status);
}
