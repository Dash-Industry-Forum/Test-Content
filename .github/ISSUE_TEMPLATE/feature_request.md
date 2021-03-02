---
name: Feature request
about: Request for new test content
title: ''
labels: request
assignees: ''

---

### A short description of the use case for the new test content.
Example: This test content is supposed to demonstrate the insertion of a midroll ad in a static MPD

### Test content requirements

#### General description and requirements
A clear and concise description of how the test content is supposed to look like. Example
* A multiperiod MPD with three periods
* Period 1 and 3 are continuous, Period 2 is an ad period
* The duration of all periods is between 10-20 seconds
* All periods contain a single video and a single audio AdaptationSet.

#### DASH-IF documents and links
* Conforming to DASH-IF Ad Insertion: https://dash-industry-forum.github.io/docs/CR-Ad-Insertion-r8.pdf
  * IF-5 conforming
  * Follow the MPD Proxy Operation Guidelines in 8.2.7.3
  * Follow the `urn:mpeg:dash:profile:cmaf:2019` profile

### Relation to CTA WAVE Test Vector database
* http://dash.akamaized.net/WAVE/vectors/
* What vectors are used from CTA WAVE Test Vector database?
* Do new vectors have to be created? If so, please add link to issue here https://github.com/cta-wave/Test-Content-Generation/issues

### Additional context
Any other information you want to add here.
