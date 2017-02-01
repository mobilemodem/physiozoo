function bin_path = download_wfdb()
%DOWNLOAD_WFDB Downloads the WFDB binaries for this OS.
%   This function detects the current OS and attempts to download the approprate WFDB binaries.
%   They will be downloaded into the folder 'bin/wfdb' under the current MATLAB directory.
%   Output:
%       bin_path: Path the the directory containing the WFDB binaries that were downloaded.

BASE_DIR = 'bin';
OUTPUT_DIR = [BASE_DIR '/wfdb'];

if ~exist(BASE_DIR, 'dir')
    mkdir(BASE_DIR)
end

t0 = cputime;

%% Determine Download URL for the current OS

% Currently this function doesn't support linux becuase

% OSX
if (ismac)
    url = 'https://homebrew.bintray.com/bottles-science/wfdb-10.5.24.yosemite.bottle.1.tar.gz';
end

% Windows
if (ispc)
    if strcmpi(computer('arch'), 'win32')
        url = 'https://physionet.org/physiotools/binaries/windows/wfdb-10.5.24-mingw32.zip';
    else
        url = 'https://physionet.org/physiotools/binaries/windows/wfdb-10.5.24-mingw64.zip';
    end 
end

% Linux
if (isunix && ~ismac)
    url = 'https://physionet.org/physiotools/binaries/intel-linux/wfdb-10.5.8-i686-Linux.tar.gz';
end

%% Clear output dir if necessary, but ask user first...
if exist(OUTPUT_DIR, 'dir')
    fprintf('[%.3f] >> download_wfdb: Output folder %s exists. Type ''YES'' to remove: ', cputime-t0, OUTPUT_DIR);
    user_response = input('', 's');
    if strcmp(user_response, 'YES')
        rmdir(OUTPUT_DIR, 's');
    else
        error('Must remove existing binary dir to re-download');
    end
end

%% Download archive
fprintf('[%.3f] >> download_wfdb: Downloading %s...\n', cputime-t0, url);

[~, url_filename, url_ext] = fileparts(url);
local_file = websave([BASE_DIR, filesep(), url_filename, url_ext], url);

%% Extract archive
fprintf('[%.3f] >> download_wfdb: Extracting %s...\n', cputime-t0, local_file);

if regexpi(url, '.tar.gz$')
    untar(local_file, OUTPUT_DIR);

elseif regexpi(url, '.zip$')
    unzip(local_file, OUTPUT_DIR);

else
    error('Unexpected file extension');
end
delete(local_file);

%% Find the bin/ directory
bin_path = [];
paths = strsplit(genpath(OUTPUT_DIR), pathsep());
for idx = 1:length(paths)
    [~, dirname, ~] = fileparts(paths{idx});
    if strcmp(dirname, 'bin')
        bin_path = paths{idx};
        break;
    end
end

if isempty(bin_path)
    error('Failed to find wfdb binaries directory in extracted archive');
end

fprintf('[%.3f] >> download_wfdb: WFDB tools downloaded to %s...\n', cputime-t0, bin_path);

end