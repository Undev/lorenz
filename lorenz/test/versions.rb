packages do
  runit '1.4'
  git '1.5'  
  rubygems '1.3.7'
  irb '0.9.5'
  rake '0.8.3'
end

package 'git-core', '1:1.5.6.5-3+lenny3.1'
package 'ruby', '1.8.7'

gems do
  ohai '2'
  unicorn '2'
end