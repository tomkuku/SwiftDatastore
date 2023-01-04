# PR
number_of_modified_files = git.modified_files.length + git.added_files.length

if git.lines_of_code > 1000 || number_of_modified_files > 100
  warn "Big PR, next time try to split changes into more than one PR"
end

# Xcode summary
xcode_summary.inline_mode = true
xcode_summary.report 'SwiftDatastore.xcresult'
