with open(r'specs\019-unified-onboarding\contracts\security-and-replay-ui.md') as f:
    for i,l in enumerate(f,1):
        if i<=60:
            print(f'{i}: {l}', end='')
